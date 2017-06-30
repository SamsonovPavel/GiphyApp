//
//  ViewController.swift
//  GiphyApp
//
//  Created by Pavel Samsonov on 26/06/2017.
//  Copyright © 2017 Pavel Samsonov. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UICollectionViewController {
    
    @IBOutlet weak var searchTextLabel: UITextField!
    @IBOutlet weak var connectIndicator: UIImageView!
    
    let realm = try! Realm()
    lazy var images: Results<Images> = {
        return self.realm.objects(Images.self)
    }()
    
    var dataImages = [Images]()
    var isLoading = false
    var loadStatus = true
    let service = NetworkingService()
    var refreshControl: UIRefreshControl!
    var footer = FooterCollectionView()
    let indicator = ActivityIndicator()
    var heightFooter: CGFloat = 0.0
    var limit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if loadStatus {
            loadData(limit: limit)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        search()
    }
}

//MARK: - Setup UI
extension SearchViewController {
    func setupUI() {
        let cellNib = UINib(nibName: ImagesCollectionViewCell.reuseId, bundle: nil)
        collectionView?.register(cellNib, forCellWithReuseIdentifier: ImagesCollectionViewCell.reuseId)
        
        let footerNib = UINib(nibName: FooterCollectionView.reuseId, bundle: nil)
        collectionView?.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                 withReuseIdentifier: FooterCollectionView.reuseId)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Загрузка...")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
        
        connectIndicator.layer.borderColor   = UIColor.darkGray.cgColor
        connectIndicator.layer.cornerRadius  = connectIndicator.bounds.width / 2.0
        connectIndicator.layer.masksToBounds = true
        
        searchTextLabel.delegate = self
        notification()
    }
}

//MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
}

//MARK: - Actions
extension SearchViewController {
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
            sself.refreshStatus()
        }
    }
    
    func search() {
        if searchTextLabel.isFirstResponder {
            searchTextLabel.resignFirstResponder()
        }
        isLoading = !isLoading
        guard let search = searchTextLabel.text, !search.isEmpty else { return }
        loadSearchImages(search: search, limit: limit, offset: 0)
    }
    
    func refreshStatus() {
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func load() {
        let offset = collectionView?.numberOfItems(inSection: 0)
        guard let text = searchTextLabel.text, !text.isEmpty else { return }
        URLCache.shared.removeAllCachedResponses()
        loadSearchImages(search: text, limit: limit, offset: offset!)
    }
    
    @objc fileprivate func refresh(sender:AnyObject) {
        if (searchTextLabel.text?.isEmpty)! {
            loadData(limit: limit)
        } else {
            load()
        }
    }
}

// MARK: Notification
extension SearchViewController {
    func notification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectReachable),
                                               name: listenerReachableNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectNotReachable),
                                               name: listenerNotReachableNotification,
                                               object: nil)
    }
    
    func connectReachable() {
        connectIndicator.backgroundColor = .green
        if loadStatus {
            if dataImages.count < limit {
                loadData(limit: limit)
            }
        }
    }
    
    func connectNotReachable() {
        connectIndicator.backgroundColor = .red
    }
}

//MARK: - Pagination for images
extension SearchViewController {
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
extension SearchViewController {
    func saveData(data: [Object]) {
        try! realm.write {
            realm.add(data, update: true)
        }
    }
    
    func loadData(limit: Int) {
        indicator.showActivityIndicator(collectionView!)
        service.getImages(limit) { [weak self] (data) in
            guard let sself = self else { return }
            guard let image = data else { return }
            
            if sself.dataImages.count > 0 {
                sself.dataImages.removeAll()
            }
            sself.indicator.hideProgressView()
            sself.dataImages.append(contentsOf: image)
//            self.saveData(data: image)
            sself.heightFooter = 0.0
            sself.collectionView?.reloadData()
            sself.refreshStatus()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchTextLabel.isFirstResponder {
            searchTextLabel.resignFirstResponder()
        }
        
        let url = dataImages[indexPath.row].original
        let imageVC = ImageViewController.instantiate(url: url)
        present(imageVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController {
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

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
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


