//
//  FavouritesTableViewController.swift
//  AMP
//
//  Created by Dmitry Yurlagin on 28.01.18.
//  Copyright © 2018 Dmitry Yurlagin. All rights reserved.
//

import UIKit

class FavouritesTableViewController: UITableViewController, FavouritesView {
  
  var onSelectItem: ((Int) -> ())?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 0
  }
 
  
}
