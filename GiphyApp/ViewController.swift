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
    
    @IBOutlet weak var searchTextLabel: UITextField!
    
    let realm = try! Realm()
    lazy var images: Results<Images> = {
        return self.realm.objects(Images.self)
    }()
    
    var dataImages = [Images]()
    var isLoading = false
    var loadStatus = true
    let service = NetworkingService()
    var footer = FooterCollectionView()
    var heightFooter: CGFloat = 0.0
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
    
    @IBAction func searchButton(_ sender: UIButton) {
    }
}

//MARK: - Setup UI
extension ViewController {
    func setupUI() {
        let cellNib = UINib(nibName: ImagesCollectionViewCell.reuseId, bundle: nil)
        collectionView?.register(cellNib, forCellWithReuseIdentifier: ImagesCollectionViewCell.reuseId)
        
        let footerNib = UINib(nibName: FooterCollectionView.reuseId, bundle: nil)
        collectionView?.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                 withReuseIdentifier: FooterCollectionView.reuseId)
        
        searchTextLabel.delegate = self
    }
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        print(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextLabel.isFirstResponder {
            searchTextLabel.resignFirstResponder()
        }
        isLoading = !isLoading
        guard let search = searchTextLabel.text, !search.isEmpty else { return true }
        loadSearchImages(search: search, limit: limit, offset: 0)
        return true
    }
}

//MARK: - Actions
extension ViewController {
    func loadSearchImages(search: String, limit: Int, offset: Int) {
        if isLoading {
            dataImages.removeAll()
            isLoading = false
            heightFooter = 70.0
        }
        service.searchImages(q: search, limit: limit, offset: offset) { [weak self] (data) in
            guard let sself = self else { return }
            guard let image = data else { return }
            
            if sself.dataImages.count < limit {
                sself.dataImages.append(contentsOf: image)
                sself.collectionView?.contentOffset = CGPoint(x: 0.0, y: -64.0)
                sself.collectionView?.reloadData()
            } else {
                var paths = [IndexPath]()
                
                image.forEach({ (image) in
                    sself.dataImages.append(image)
                    paths.append(IndexPath.init(item: sself.dataImages.endIndex - 1, section: 0))
                })
                DispatchQueue.main.async {
                    sself.collectionView?.insertItems(at: paths)
                }
            }
        }
    }
    
    func load() {
        let offset = collectionView?.numberOfItems(inSection: 0)
        guard let text = searchTextLabel.text, !text.isEmpty else { return }
        loadSearchImages(search: text, limit: limit, offset: offset!)
    }
}

//MARK: - Pagination for images
extension ViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        let offset = scrollView.contentOffset.y
        let height = scrollView.contentSize.height < collectionView.frame.size.height ?
                                                     collectionView.frame.size.height :
                                                     scrollView.contentSize.height
        
        let max = height - collectionView.frame.size.height
        loadStatus = offset < max ? false : loadStatus

        if offset > max && !loadStatus {
            loadStatus = true
            load()
        }
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
        service.getImages(limit) { [weak self] (data) in
            guard let sself = self else { return }
            guard let image = data else { return }
            sself.dataImages.append(contentsOf: image)
//            self.saveData(data: image)
            sself.collectionView?.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchTextLabel.isFirstResponder {
            searchTextLabel.resignFirstResponder()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height - (collectionView.frame.height - heightFooter))
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: FooterCollectionView.reuseId,
                                                                     for: indexPath) as! FooterCollectionView
        }
        return footer
    }
}




















