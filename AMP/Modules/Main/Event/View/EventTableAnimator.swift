//
//  EventTableAnimator.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 15/01/2019.
//  Copyright © 2019 Dmitry Yurlagin. All rights reserved.
//

import TableKit
import DifferenceKit
import CoreLocation

class EventTableAnimator {
  private weak var tableView: UITableView?
  private let tableDirector: TableDirector
  private lazy var commentsSectionHeaderView = CommentsSectionHeaderView.nib()
  private var onPressComment: () -> Void
  private let onSelectComment: (CommentId) -> Void
  
  var props: EventViewController.Props? {
    didSet {
      let commentsSectionHeaderProps: CommentsSectionHeaderView.Props
      if let props = props {
        switch props.loadCommentsStatus {
        case .canLoadMore, .error: commentsSectionHeaderProps = .moreButton(onTap: props.onLoadMoreComments)
        case .loadingMore: commentsSectionHeaderProps = .loadingMore
        case .fullLoaded: commentsSectionHeaderProps = .none
        }
        commentsSectionHeaderView.props = commentsSectionHeaderProps
      }
      scheduleTableViewUpdating()
    }
  }
  
  private struct State {
    var event: Event?
    var userLocation: CLLocation?
  }
  
  private var state = State(event: nil, userLocation: nil)
  
  init(tableView: UITableView, onPressComment: @escaping () -> Void, onSelectComment: @escaping (CommentId) -> Void) {
    self.tableView = tableView
    self.onPressComment = onPressComment
    self.onSelectComment = onSelectComment
    tableDirector = TableDirector(tableView: tableView)
  }
  
  private var isTableViewAnimating = false
  
  
  private func makeSection(rows: [Row]) -> TableSection {
    let section = TableSection(rows: rows)
    section.headerHeight = .leastNormalMagnitude
    section.footerHeight = .leastNormalMagnitude
    return section
  }
  
  private func makeDatasourceFromState() -> [TableSection] {
    var eventSection: TableSection?
    if let event = state.event {
      let eventCellProps = makeEventCellProps(event: event, userLocation: state.userLocation)
      let eventRow = TableRow<EventDetailsCell>(item: eventCellProps)
      eventSection = makeSection(rows: [eventRow])
    }
    
    var commentsSection: TableSection?
    if let comments = state.event?.comments {
      let commentRows = comments
        .map{CommentTableViewCell.Props(comment: $0, isSolution: $0.id == state.event!.solutionCommentId)}
        .map{TableRow<CommentTableViewCell>(item: $0)}
      commentsSection = commentRows.isEmpty ? nil : makeSection(rows: commentRows)
    }
    return [eventSection, commentsSection].compactMap{$0}
  }
  
  private func makeEventCellProps(event: Event, userLocation: CLLocation?) -> EventDetailsCell.Props {
    let distance: String
    if let userLocation = userLocation {
      let eventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
      distance = String(format: "%.1f км.", arguments: [eventLocation.distance(from: userLocation) / 1000])
    } else {
      distance = "???"
    }
    return EventDetailsCell.Props(
      event: event,
      distance: distance,
      onLike: props?.onLike,
      onDislike: props?.onDislike,
      onComment: onPressComment
    )
  }
  
  private enum Section: Differentiable {
    case event
    case comments
  }
  
  private func makeCommentsSection(from event: Event) -> ArraySection<Section, AnyDifferentiable>? {
    guard let comments = event.comments else { return nil }
    return ArraySection(
      model: .comments,
      elements: comments
        .map{CommentTableViewCell.Props.init(comment: $0, isSolution: event.solutionCommentId == $0.id)}
        .map(AnyDifferentiable.init)
    )
  }
  
  private func getCommentsSectionHeaderHeight() -> CGFloat {
    guard let props = props else { return .leastNormalMagnitude }
    switch props.loadCommentsStatus {
    case .fullLoaded:
      return .leastNormalMagnitude
    default:
      return commentsSectionHeaderView.intrinsicContentSize.height
    }
  }
  
  func scheduleTableViewUpdating() {
    guard !isTableViewAnimating else { return }
    
    var sourceEventSection: ArraySection<Section, AnyDifferentiable>?
    var sourceCommentsSection: ArraySection<Section, AnyDifferentiable>?
    if let event = state.event {
      sourceEventSection = ArraySection(
        model: .event,
        elements: [makeEventCellProps(event: event, userLocation: state.userLocation)]
          .map(AnyDifferentiable.init)
      )
      sourceCommentsSection = makeCommentsSection(from: event)
    }
    
    var destinationEventSection: ArraySection<Section, AnyDifferentiable>?
    var destinationCommentsSection: ArraySection<Section, AnyDifferentiable>?
    if let event = props?.event {
      destinationEventSection = ArraySection(
        model: Section.event,
        elements: [AnyDifferentiable(makeEventCellProps(event: event,
                                                        userLocation: props?.userLocation))])
      destinationCommentsSection = makeCommentsSection(from: event)
    }
    
    let changeSet = StagedChangeset(
      source: [sourceEventSection, sourceCommentsSection].compactMap{$0},
      target: [destinationEventSection, destinationCommentsSection].compactMap{$0}
    )
    
    
    if !changeSet.isEmpty {
      isTableViewAnimating = true
      tableView?.reload(
        using: changeSet,
        with: .none) { [weak self] dataSet in
          let sections: [TableSection] = dataSet.map{ section in
            switch section.model {
            case .event:
              let rows = section.elements
                .compactMap{$0.base as? EventDetailsCell.Props}
                .map{TableRow<EventDetailsCell>(item: $0)}
              return makeSection(rows: rows)
              
            case .comments:
              let rows = section.elements
                .compactMap{$0.base as? CommentTableViewCell.Props}
                .map{TableRow<CommentTableViewCell>(item: $0)
                  .on(.select) { options in
                    self?.tableView?.selectRow(at: nil, animated: true, scrollPosition: .none)
                    self?.onSelectComment(options.item.comment.id)
                  }
              }
              let commentSection = TableSection(
                headerView: commentsSectionHeaderView,
                footerView: nil,
                rows: rows
              )
              commentSection.headerHeight = getCommentsSectionHeaderHeight()
              commentSection.footerHeight = .leastNormalMagnitude
              return commentSection
            }
          }
          self?.state.event = self?.props?.event
          self?.state.userLocation = self?.props?.userLocation
          tableDirector.replaceAllSections(with: sections)
          self?.isTableViewAnimating = false
          self?.scheduleTableViewUpdating()
      }
    }
  }
}
