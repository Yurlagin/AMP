//
//  EventListTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import TableKit
import DifferenceKit

typealias ScreenId = String // TODO: - might remove!

class EventListViewController: UIViewController, EventListView {
  
  // MARK: - EventListView
  var onSelect: ((EventId) -> ())?
  var onTapComment: ((EventId) -> ())?
  
  // MARK: - EventListViewInput
  
  private var props: Props? {
    didSet {
      scheduleTableViewUpdating()
    }
  }
  
  var output: EventListViewOutput?
  
  private lazy var tableView = makeTableView()
  private var refreshControl: UIRefreshControl? { return tableView.refreshControl }
  private lazy var tableDirector = TableDirector(tableView: tableView)
  private var bottomSpinner: UIActivityIndicatorView!
  private let tableFooterHeight: CGFloat = 44
  private var isTableViewAnimating = false
  
  private var state = State(events: [])
  private struct State {
    var events: [Event]
  }
  
  private func ajustFooterHeight() {
    let footerView = tableView.tableFooterView!
    footerView.frame.size.height = props?.spinner == .bottom ? tableFooterHeight : 0
    tableView.tableFooterView = footerView
  }
  
  private func scheduleTableViewUpdating() {
    guard !isTableViewAnimating else { return }
    let newEvents = props?.events ?? []
    let changeSet = StagedChangeset(source: self.state.events, target: newEvents)
    guard !changeSet.isEmpty else {
      return
    }
    var remainingStagesCount = changeSet.count
    tableView.reload(
      using: changeSet,
      with: .none) { [weak self] newRows in
        let rows = newRows.map(makeEventRow)
        let section = TableSection(rows: rows)
        section.headerHeight = .leastNormalMagnitude
        section.footerHeight = .leastNormalMagnitude
        self?.tableDirector.replaceAllSections(with: [section])
        remainingStagesCount -= 1
        if remainingStagesCount == 0 {
          self?.state.events = newRows
          self?.isTableViewAnimating = false
          self?.scheduleTableViewUpdating()
        }
    }
  }
  
  private func makeEventRow(from event: Event) -> TableRow<EventListTableViewCell> {
    let props = self.props!
    return
      TableRow(
        item: EventListTableViewCell.Props(
          event: event,
          didTapLike: props.didTapLike,
          didTapDislike: props.didTapDislike,
          commentPressed: { [unowned self] in self.onTapComment?(event.id) },
          currentUserLocation: props.userLocation)
        ).on(.willDisplay) { [unowned self] in
          self.props?.willDisplayCellAtIndex($0.indexPath.row)
        }.on(.select) { [unowned self] in
          self.onSelect?($0.item.event.id)
    }
  }
  
  private func setTopSpinner(isAnimating: Bool) {
    if isAnimating {
      if !refreshControl!.isRefreshing {
        setRefreshingContentOffset()
        tableView.refreshControl?.beginRefreshing()
      }
    } else if refreshControl!.isRefreshing {
      tableView.refreshControl!.endRefreshing()
    }
  }
  
  private func setBottomSpinner(isAnimating: Bool) {
    guard isAnimating != bottomSpinner.isAnimating else { return }
    if isAnimating {
      bottomSpinner.startAnimating()
    } else {
      bottomSpinner.stopAnimating()
    }
  }
  
  @objc func onRefresh(_ sender: UIRefreshControl) {
    props?.onRefreshTableView()
  }
  
  private func setRefreshingContentOffset() {
    tableView.setContentOffset (
      CGPoint(x: 0, y:  tableView.contentOffset.y - refreshControl!.frame.size.height),
      animated: false
    )
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "События вокруг"
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .automatic
    }
    output?.onViewDidLoad()
  }
  
  override func loadView() {
    view = tableView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
    output?.onViewWillAppear()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    output?.onViewDidDissapear()
  }
  
  private func makeTableView() -> UITableView {
    let tableView = UITableView(frame: .zero)
    tableView.backgroundColor = .groupTableViewBackground
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    tableView.refreshControl = refreshControl
    
    let bottomSpinner = UIActivityIndicatorView(style: .gray)
    bottomSpinner.hidesWhenStopped = true
    self.bottomSpinner = bottomSpinner
    
    let footerView = UIView()
    footerView.frame.size.height = 0// tableFooterHeight
    footerView.addSubview(bottomSpinner)
    bottomSpinner.center.x = UIScreen.main.bounds.size.width / 2
    bottomSpinner.center.y = tableFooterHeight / 2
    footerView.clipsToBounds = true
    tableView.tableFooterView = footerView
    
    if #available(iOS 11.0, *) { } else {
      let contentInsets = UIEdgeInsets.init(top: topBarHeight, left: 0, bottom: tabbarHeight, right: 0)
      tableView.contentInset = contentInsets
      tableView.scrollIndicatorInsets = contentInsets
    }
    return tableView
  }
}

extension EventListViewController: EventListViewInput {
  
  func renderProps(_ props: Props) {
    switch props.spinner {
    case .none:
      self.setTopSpinner(isAnimating: false)
      self.setBottomSpinner(isAnimating: false)
      
    case .top:
      self.setTopSpinner(isAnimating: true)
      self.setBottomSpinner(isAnimating: false)
      
    case .bottom:
      self.setTopSpinner(isAnimating: false)
      self.setBottomSpinner(isAnimating: true)
    }
    self.props = props
    ajustFooterHeight()
  }
  
}
