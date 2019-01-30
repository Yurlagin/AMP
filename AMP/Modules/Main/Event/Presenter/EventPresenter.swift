//
//  EventPresenter.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 14/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import ReSwift

class EventPresenter {
  
  private weak var view: EventViewInput?
  private var eventId: EventId
  
  private struct State {
    var inputFormStatus: CommentInputView.Props
    var commentType: CommentType
  }
  
  init(view: EventViewInput, eventId: EventId) {
    self.view = view
    self.eventId = eventId
  }
  
  //  private lazy var onSendComment: (_ message: String) -> () = { [unowned self] message in
  //    store.dispatch({ (state, store) -> Action? in
  //      guard let event = state.eventsState.getEventBy(id: self.eventId) else {
  //        assertionFailure("We shouldn't be here")
  //        return nil
  //      }
  //      guard let token = store.state.authState.loginStatus.userCredentials?.token else { return nil}
  //
  //      var replay: Int?
  //      var thank: Bool?
  //      guard let commentType = state.eventsState.allEvents[event.id]?.commentDraft.type else {
  //        assertionFailure("We shouldn't be here")
  //        return nil
  //      }
  
  //      if case .answer(let replayId) = commentType {
  //        replay = replayId
  //      } else if case .resolve (let replayId) = commentType {
  //        replay = replayId
  //        thank = true
  //      }
  
  //      let request = AddCommentRequest(
  //        comment: message,
  //        eventid: event.id,
  //        token: token,
  //        replyTo: replay,
  //        thank: thank
  //      )
  //
  //
  ////      self.state.inputFormStatus = .blocked(quote: inputState.inputFormStatus.quote)
  //      self.eventsService.postComment(request)
  //        .then { [weak self] comment -> Void in
  //          self?.state.inputFormStatus = .clear(onSendComment: self?.onSendComment)
  //          store.dispatch(SentComment(eventId: event.id, comment: comment ))
  //        }
  //        .catch { [weak self] error in
  //          self?.state.inputFormStatus = .normal(quote: inputState.inputFormStatus.quote,
  //                                                onSendComment: self?.onSendComment)
  //          store.dispatch(SendCommentError(eventId: event.id, error: error ))
  //      }
  //      return SendComment(eventId: self.eventId)
  //    })
  //
  //  }
  
}

extension EventPresenter: EventViewOutput {
  
  func onViewDidLoad() {
    
  }
  
  func onViewWillAppear() {
    store.subscribe(self)
  }
  
  func onViewDidDissapear() {
    store.unsubscribe(self)
  }
  
}

extension EventPresenter: StoreSubscriber {
  
  func newState(state: AppState) {
    guard let eventStatus = state.eventsState.allEvents[eventId] else {
      assertionFailure("We shouldn't be here")
      return
    }
    let event = eventStatus.event
    
    var quote: CommentQuote?
    switch eventStatus.commentDraft.type {
    case .answer(let commentId), .resolve(let commentId):
      if let comment = event.comments?.first(where: {$0.id == commentId}) {
        quote = CommentQuote(userName: comment.userName ?? "Без Имени",
                             message: comment.message ?? "Нет комментария")
      }
    default:
      break
    }
    
    let commentsCount = (event.comments ?? []).count
    let pagelimit = state.eventsState.settings.commentPageLimit
    let offset = max(event.commentsCount - commentsCount - pagelimit, 0)
    let limit = offset > 0 ? pagelimit : event.commentsCount - commentsCount
    let loadCommentsPageAction = LoadCommentsPage(
      eventId: eventId,
      limit: limit,
      offset: offset,
      maxId: event.maxCommentId ?? 0)
    
    let commentAction: (CommentId) -> CommentLikeAction = { commentId in
      event.comments!.first(where: {$0.id == commentId})!.like ? .removeLikeComment : .addLikeComment
    }
    
    let props = EventViewController.Props(
      event: event,
      userLocation: state.locationState.currentlocation,
      loadCommentsStatus: {
        switch eventStatus.loadCommentsStatus {
        case .none:
          if event.commentsCount > (event.comments ?? []).count {
            return .canLoadMore
          }
          return .fullLoaded
        case .error:
          return .error
        case .loading:
          return .loadingMore
        }}(),
      onLike: { store.dispatch(EventLikeInvertAction(eventId: event.id)) },
      onDislike: { store.dispatch(EventDislikeInvertAction(eventId: event.id)) },
      onLikeComment: { commentId in
        store.dispatch(CommentLikeInvertAction(
          eventId: event.id,
          commentId: commentId,
          action: commentAction(commentId)
        ))},
      onSendComment: { store.dispatch(SendComment(eventId: event.id)) }  ,
      onLoadMoreComments: { store.dispatch(loadCommentsPageAction) },
      draftText: eventStatus.commentDraft.text,
      commentQuote: quote,
      isInputViewBlocked: eventStatus.commentDraft.postingState == .loading,
      onDraftMessage: { store.dispatch(ChangeCommentDraftText(eventId: event.id, text: $0)) },
      onChangeCommentType: { store.dispatch(ChangeCommentDraftType.init(eventId: event.id, type: $0)) },
      errorAlert: eventStatus.commentDraft.postingState == .error
        ? EventViewController.Props.ErrorAlert(
          text: "Что-то пошло не так. Пожалуйста, повторите попытку позже.",
          onTap: { store.dispatch(DidShowCommentPostingError(eventId: event.id)) }
          )
        : nil
    )
    view?.renderProps(props)
  }
}
