//
//  EventListTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class EventListTableViewController: UITableViewController, EventListView {
 
  var viewModel: EventListViewModel! {
    didSet {
//      print (viewModel)
      viewModelRendered = false
      view.setNeedsLayout()
    }
  }
  
  private var firstViewModelRendered = false
  private var viewModelRendered = false
  
  var onSelectItem: ((Int) -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = tableView.rowHeight
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
