//
//  EventListTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class EventListTableViewController: UITableViewController, EventListView {
  
  @IBAction func userDidRefreshTable(_ sender: UIRefreshControl) {
    viewModel.onRefreshTableView?()
  }
  
  var viewModel: EventListViewModel! {
    didSet {
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  private var firstViewModelRendered = false
  private var viewModelRendered = false
  
  var onSelectItem: ((Int) -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 193
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self) { $0.select { $0.eventListState } }
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
  }
  
  private func render(viewModel: EventListViewModel) {
    if !firstViewModelRendered {
      viewModel.onDidLoad?()
      firstViewModelRendered = true
    }
    switch viewModel.spinner {
    case .none: topSpinner(isRefreshing: false); bottomSpinner(isRefreshing: false)
    case .top: topSpinner(isRefreshing: true); bottomSpinner(isRefreshing: false)
    case .bottom: topSpinner(isRefreshing: false); bottomSpinner(isRefreshing: true)
    }
    tableView.reloadData()
  }
  
  private func topSpinner(isRefreshing: Bool) {
    if isRefreshing && tableView.refreshControl?.isRefreshing == false {
      tableView.refreshControl?.beginRefreshing()
    } else {
      if tableView.refreshControl?.isRefreshing == true {
        tableView.refreshControl?.endRefreshing()
      }
    }
  }
  
  private func bottomSpinner(isRefreshing: Bool) {
    //
  }

  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.events.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Event Cell", for: indexPath) as! EventListTableViewCell
    cell.renderUI(event: viewModel.events[indexPath.row])
    return cell
  }
  
  
  
}
