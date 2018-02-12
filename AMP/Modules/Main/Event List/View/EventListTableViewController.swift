//
//  EventListTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit
import DeepDiff

class EventListTableViewController: UITableViewController, EventListView {
  
  @IBAction func userDidRefreshTable(_ sender: UIRefreshControl) {
    viewModel.onRefreshTableView?()
  }
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var bottomSpinner: UIActivityIndicatorView!
  
  var viewModel: EventListViewModel! {
    didSet {
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  var rowHeights = [Int: CGFloat]()
  
  var events = [Event]()
  
  private var firstViewModelRendered = false
  private var viewModelRendered = false
  
  var onSelectItem: ((Int) -> ())?
  
  
  private func render(viewModel: EventListViewModel) {
    let changes = diff(old: events, new: viewModel.events)
    events = viewModel.events
    tableView.reload(changes: changes, completion: { _ in })
    
    switch viewModel.spinner {
    case .none: topSpinner(isRefreshing: false); bottomSpinner(isRefreshing: false)
    case .top: topSpinner(isRefreshing: true); bottomSpinner(isRefreshing: false)
    case .bottom: topSpinner(isRefreshing: false); bottomSpinner(isRefreshing: true)
    }
  }
  
  
  private func topSpinner(isRefreshing: Bool) {
    if isRefreshing, !refreshControl!.isRefreshing{
      setRefreshingContentOffset()
      refreshControl!.beginRefreshing()
    } else if refreshControl!.isRefreshing {
        refreshControl!.endRefreshing()
    }
  }
  
  
  private func bottomSpinner(isRefreshing: Bool) {
    
    func updateFooterHeight() {
      tableView.tableFooterView?.frame.size.height = isRefreshing ? 44 : 0
      tableView.beginUpdates()
      tableView.endUpdates()
    }
    
    if isRefreshing {
      if !bottomSpinner.isAnimating {
        bottomSpinner.startAnimating()
        updateFooterHeight()
      }
    } else {
      if bottomSpinner.isAnimating {
        bottomSpinner.stopAnimating()
        updateFooterHeight()
      }
    }
  }
  
  
  private func setRefreshingContentOffset() {
    tableView.setContentOffset(CGPoint(x: 0, y:  self.tableView.contentOffset.y - refreshControl!.frame.size.height), animated: true)
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 193
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !firstViewModelRendered {
      viewModel.onRefreshTableView?()
      firstViewModelRendered = true
    }
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.unsubscribe(self)
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if !viewModelRendered {
      render(viewModel: viewModel)
      viewModelRendered = true
    }
    
    if !firstViewModelRendered {
      topSpinner(isRefreshing: true)
      viewModel.onRefreshTableView?()
      firstViewModelRendered = true
    }

  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Event Cell", for: indexPath) as! EventListTableViewCell
    cell.renderUI(event: events[indexPath.row])
    store.subscribe(cell) { $0.select {$0.locationState} }
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    viewModel.willDisplayCellAtIndex?(indexPath.row)
    if rowHeights[indexPath.row] == nil {
      rowHeights[indexPath.row] = cell.frame.height
    }
  }
  
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    store.unsubscribe(cell as! EventListTableViewCell)
  }
  
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return rowHeights[indexPath.row] ?? 193
  }

  
  
}
