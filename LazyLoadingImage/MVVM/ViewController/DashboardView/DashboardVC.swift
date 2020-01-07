//
//  DashboardVC.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: DashboardViewModel?
    
    var footerView: CustomFooterView?
    
    var pageNumber : Int = 1
    
    let footerViewReuseIdentifier = "RefreshFooterView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.fetchPicSumPhotosList(page: pageNumber)
    }
    
    //MARK: Get PicSum Photos List WebService
    public func fetchPicSumPhotosList(page: Int) {
                
        PicsumClient.shared.getPicSumPhotosList(page: "\(page)", vc: self, completion: { (result) in
            switch result {
            case .success(let responseObj):
                //initialize CurrentWeatherViewModel
                if self.pageNumber == 1 {
                    self.viewModel = DashboardViewModel(vc: self, picSumPhotosModel: responseObj!)
                    self.setupView()
                } else {
                    if let picSumPhotosModel: PicSumPhotosModel = responseObj {
                        for element in picSumPhotosModel {
                            self.viewModel!.picSumPhotosModel.append(element)
                        }
                    }
                    self.viewModel?.loadMore = false
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    private func setupView() {
        self.collectionView.delegate = viewModel
        self.collectionView.dataSource = viewModel
        
        self.collectionView?.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerViewReuseIdentifier)
    }

}

