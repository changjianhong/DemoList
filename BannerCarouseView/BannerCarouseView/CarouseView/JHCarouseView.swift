//
//  JHCarouseView.swift
//  BannerCarouseView
//
//  Created by changjianhong on 16/3/22.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

import UIKit

protocol JHCarouseViewDataSourse {
  func carouseView(carouseView:JHCarouseView, completion:(banners:Array<Banner>)->());
}

protocol JHCarouseViewDelegate {
  func carouseView(carouseView:JHCarouseView, didSelectedItem banners:Banner);
}

class JHCarouseView: UIView {
  
  var delegate:JHCarouseViewDelegate?
  var dataSource:JHCarouseViewDataSourse?
  
  var _currentImageView:UIImageView!
  var _nextImageView:UIImageView!
  var _currentPageIndex = 0
  
  lazy var _scrollView: UIScrollView = {
    let scrollView                            = UIScrollView()
    scrollView.frame                          = self.bounds
    scrollView.contentSize                    = CGSizeMake(self.width * 3, self.height);
    scrollView.pagingEnabled                  = true
    scrollView.delegate                       = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.contentOffset                  = CGPointMake(self.width, 0)
    return scrollView;
  }()
  
  lazy var _pageControl: UIPageControl = {
    let pageControl = UIPageControl(frame: CGRectMake(0, self.height - 30, self.width, 20))
    return pageControl
  }()
  
  var _banners:Array<Banner>?
  var _bannerTimer:NSTimer?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(_scrollView)
    _currentImageView = UIImageView(frame: CGRectMake(self.width, 0, self.width, self.height))
    _scrollView.addSubview(_currentImageView)
    
    _nextImageView = UIImageView(frame: self.bounds)
    _scrollView.addSubview(_nextImageView)
    
    _currentImageView.contentMode = .ScaleAspectFill
    _nextImageView.contentMode = .ScaleAspectFill
    
    self.addSubview(_pageControl)
    let tap = UITapGestureRecognizer(target: self, action: Selector("tap"))
    self.addGestureRecognizer(tap)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func scheduledScoll() {
    _scrollView.setContentOffset(CGPointMake(self.width * 2, 0), animated: true)
  }
  
  func __scrollViewDidEndScroll() {
    if _banners == nil {
      return
    }
    let count = _banners!.count
    if _scrollView.contentOffset.x < self.width {
      _currentPageIndex = (_currentPageIndex + count - 1) % count
    } else if _scrollView.contentOffset.x > self.width {
      _currentPageIndex = (_currentPageIndex + 1) % count
    }
    _scrollView.contentOffset = CGPointMake(self.width, 0)
    _currentImageView.image = UIImage(named: _banners![_currentPageIndex].coverURL!)
    _pageControl.currentPage = _currentPageIndex
    self.resumeAutomaticScrolling()
  }
  
  
  func tap() {
    print(_currentPageIndex)
  }
}

//public
extension JHCarouseView {
  func reloadCarouseBanners() {
    dataSource?.carouseView(self, completion: { (banners) -> () in
      self._banners = banners
      self._pageControl.numberOfPages = banners.count
      self._currentImageView.image = UIImage(named: (banners.first?.coverURL)!)
      self.resumeAutomaticScrolling()
    })
  }
  
  func resumeAutomaticScrolling() {
    if ((_bannerTimer?.valid) == nil && _banners!.count > 0) {
      _bannerTimer = NSTimer(timeInterval: 5.0, target: self, selector: Selector("scheduledScoll"), userInfo: nil, repeats: true)
      NSRunLoop.currentRunLoop().addTimer(_bannerTimer!, forMode:NSDefaultRunLoopMode)
    }
  }
  
  func stopAutomaticScrolling() {
    if ((_bannerTimer?.valid) == nil) {
      _bannerTimer?.invalidate()
    }
  }
}

extension JHCarouseView: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    self.stopAutomaticScrolling()
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    self.__scrollViewDidEndScroll()
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    self.__scrollViewDidEndScroll()
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView.contentOffset.x < scrollView.width {
      // ----->
      _nextImageView.left = 0
      _nextImageView.image = UIImage(named: _banners![(_currentPageIndex - 1 + _banners!.count) % _banners!.count].coverURL!)
    } else if scrollView.contentOffset.x > scrollView.width {
      // <-----
      _nextImageView.left = self.width * 2
      _nextImageView.image = UIImage(named: _banners![(_currentPageIndex + 1 + _banners!.count) % _banners!.count].coverURL!)
    }
  }
}