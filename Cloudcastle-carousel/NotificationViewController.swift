//
//  NotificationViewController.swift
//  Cloudcastle-carousel
//
//  Created by Bryan Marks on 3/8/19.
//  Copyright © 2019 Bryan Marks. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 200, height: 185)
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.register(CarouselNotificationCell.self, forCellWithReuseIdentifier: "CarouselNotificationCell")
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImage(named: "Back")?.withRenderingMode(.alwaysTemplate)
        
        button.setImage(img, for: .normal)
        button.tintColor = UIColor.black
//        button.backgroundColor = MessagesView.background
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return button
    }()
    
    
    var bestAttemptContent: UNMutableNotificationContent?
    
    var iterableContent =  [AnyHashable : Any]()
    
    var carouselImages : [String] = [String]()
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        print("viewDidLoad")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
//        collectionView.addSubview(backButton)
////        backButton.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
//        backButton.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 50).isActive = true
//        backButton.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: 50).isActive = true
////        backButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//
////        backButton.addTarget(scrollNextItem, action: Selector
//        backButton.addTarget(self, action: #selector(scrollNextItem), for: .touchUpInside)
//        collectionView.heightAnchor.constraint(equalToConstant: 185).isActive = true
//        collectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    func didReceive(_ notification: UNNotification) {
        
        
        self.bestAttemptContent = (notification.request.content.mutableCopy() as? UNMutableNotificationContent)
        
        self.iterableContent = notification.request.content.userInfo
        
        print("self.iterableContent \(self.iterableContent)")
        
         if let imagesStr = self.iterableContent["images"] as? String {
            print(imagesStr)
            let list = imagesStr.components(separatedBy: ",")
            
            print("list \(list)")
            
            self.carouselImages = list
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        if let title = self.iterableContent["title"] as? String {
            print(title)
        }
        if let deep_link = self.iterableContent["deep_link"] as? String {
            print(deep_link)
        }
        
        
        
        
        
        print("self.bestAttemptContent \(String(describing: self.bestAttemptContent))")
        
//        if let bestAttemptContent =  bestAttemptContent {
//            
//            if let carouselStr = bestAttemptContent.body as? String {
//                
//                let list = carouselStr.components(separatedBy: ",")
//                
//                print("list \(list)")
//                
//                self.carouselImages = list
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//                
//            } else {
//                //handle non localytics rich push
//            }
//        }
        

    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "myNotificationCategory.next" {
            self.scrollNextItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        }else if response.actionIdentifier == "myNotificationCategory.previous" {
            self.scrollPreviousItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        }else {
            completion(UNNotificationContentExtensionResponseOption.dismissAndForwardAction)
        }
    }
    
    
    private func scrollNextItem(){
        self.currentIndex == (self.carouselImages.count - 1) ? (self.currentIndex = 0) : ( self.currentIndex += 1 )
        let indexPath = IndexPath(row: self.currentIndex, section: 0)
        self.collectionView.contentInset.right = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.contentInset.left = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
    }
    
    private func scrollPreviousItem(){
        self.currentIndex == 0 ? (self.currentIndex = self.carouselImages.count - 1) : ( self.currentIndex -= 1 )
        let indexPath = IndexPath(row: self.currentIndex, section: 0)
        self.collectionView.contentInset.right = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.contentInset.left = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? 10.0 : 20.0
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }
    
}

extension NotificationViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item!!!!")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.carouselImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "CarouselNotificationCell"
        self.collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CarouselNotificationCell
        let imagePath = self.carouselImages[indexPath.row]
        cell.configure(imagePath: imagePath)
        cell.layer.cornerRadius = 8.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        let cellWidth = (indexPath.row == 0 || indexPath.row == self.carouselImages.count - 1) ? (width - 30) : (width - 40)
        return CGSize(width: cellWidth, height: width - 20.0)
    }
    
}
