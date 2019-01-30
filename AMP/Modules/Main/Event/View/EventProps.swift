//
//  EventProps.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 14/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import CoreLocation

struct CommentQuote {
  let userName: String
  let message: String
}

extension CommentQuote: Hashable {}

extension EventViewController {

  struct Props {
    let event: Event
    let userLocation: CLLocation?
    let loadCommentsStatus: LoadCommentsStatus
    let onLike: () -> ()
    let onDislike: () -> ()
    let onLikeComment: (CommentId) -> ()
    let onSendComment: () -> ()
    let onLoadMoreComments: () -> ()
    let draftText: String
    let commentQuote: CommentQuote?
    let isInputViewBlocked: Bool
    let onDraftMessage: (String) -> ()
    let onChangeCommentType: (CommentType) -> ()
    let errorAlert: ErrorAlert?
    
    enum LoadCommentsStatus {
      case canLoadMore
      case loadingMore
      case error
      case fullLoaded
    }
    
    struct ErrorAlert {
      let text: String
      let onTap: () -> Void
    }
  }
}

//extension Event {
//  var hasMoreComments: Bool { return [comments ?? []].count < commentsCount }
//}
