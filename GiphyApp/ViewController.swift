//
//  ViewController.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UICollectionViewController {
    
    let realm = try! Realm()
    lazy var images: Results<Images> = {
        return self.realm.objects(Images.self)
    }()
    
    var dataImages = [Images]()
    var isLoading = false
    let service = NetworkingService()
    var limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData(limit: limit)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Setup UI

extension ViewController {
    func setupUI() {
        let cellNib = UINib(nibName: ImagesCollectionViewCell.reuseId, bundle: nil)
        collectionView?.register(cellNib, forCellWithReuseIdentifier: ImagesCollectionViewCell.reuseId)
    }
}

//MARK: - Networking

extension ViewController {
    
    func saveData(data: [Object]) {
        try! realm.write {
            realm.add(data, update: true)
        }
    }
    
    func loadData(limit: Int) {
        guard !isLoading else { return }
        isLoading = true
        service.getImages(limit) { (data) in
            self.isLoading = false
            guard let image = data else { return }
            self.dataImages.append(contentsOf: image)
            self.saveData(data: image)
            self.collectionView?.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagesCollectionViewCell.reuseId, for: indexPath) as! ImagesCollectionViewCell
        cell.configure(images: dataImages[indexPath.row])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

fileprivate let inset: CGFloat = 1.0

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = (view.frame.width / 2.0) - 1.5
        let heightPerItem = widthPerItem + widthPerItem / 10.0
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return inset
    }
}




















