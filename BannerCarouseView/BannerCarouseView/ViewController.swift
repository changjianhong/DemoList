//
//  ViewController.swift
//  BannerCarouseView
//
//  Created by changjianhong on 16/3/22.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var banners:Array<Banner> = {
    let banner1 = Banner()
    banner1.coverURL = "1.jpg";
    let banner2 = Banner()
    banner2.coverURL = "2.jpg";
    let banner3 = Banner()
    banner3.coverURL = "3.jpg";
    let banner4 = Banner()
    banner4.coverURL = "4.jpg";
    
    let array = [banner1, banner2, banner3, banner4]
    return array
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let carouseView = JHCarouseView(frame: CGRectMake(0, 0, self.view.width, 200))
    carouseView.delegate = self
    carouseView.dataSource = self
    self.view.addSubview(carouseView)
    carouseView.reloadCarouseBanners()
  }
}

extension ViewController:JHCarouseViewDataSourse, JHCarouseViewDelegate {
  func carouseView(carouseView: JHCarouseView, didSelectedItem banners: Banner) {
    
  }
  
  func carouseView(carouseView: JHCarouseView, completion: (banners: Array<Banner>) -> ()) {
    completion(banners: banners)
  }
}

