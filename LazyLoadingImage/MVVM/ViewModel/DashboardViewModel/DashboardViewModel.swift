//
//  DashboardViewModel.swift
//  LazyLoadingImage
//
//  Created by Neosoft on 07/01/20.
//  Copyright © 2020 Neosoft. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewModel: NSObject {

    var picSumPhotosModel: PicSumPhotosModel
    private var vc: DashboardVC?
        
    var itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    var loadMore: Bool = false
    
    var selectedCellFrame: CGRect?
    var selectedIndexPath: IndexPath?
    
    public init(vc: DashboardVC, picSumPhotosModel: PicSumPhotosModel) {
        self.vc = vc
        self.picSumPhotosModel = picSumPhotosModel
    }
    
}

// MARK: UICollectionViewDataSource
extension DashboardViewModel: UICollectionViewDataSource {
    // there's one search per section, to number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // number of items in a section is the count of the searchResults array from the relevant FlickrSearchObject
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picSumPhotosModel.count
    }
    
    
    // configure cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // the cell coming back is a PicSumPhotosCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicSumPhotosCell.identifier, for: indexPath) as! PicSumPhotosCell
        
        cell.imageView.isUserInteractionEnabled = true
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension DashboardViewModel: UICollectionViewDelegate {
    
    // this method allows adding selected photos to the shared photos array and updates the shareTextLabel
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        //TODO: enlarge image when user click on thumbnail with higher resolution
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            loadMorePhotos()
        }
        
        let picSumPhotoElement = picSumPhotosModel[indexPath.row]
        
        (cell as! PicSumPhotosCell).imageView.image = UIImage(named: "placeholder")
        
        //Image Download Manager
        //@param:   picSumElement: PicSumPhotosModelElement
        //          indexPath: IndexPath?
        //          imageSize: Int -> height and width for image size
        ImageDownloadManager.shared.downloadImage(picSumPhotoElement, indexPath: indexPath, imageSize: 120) { (image, url, indexPathh, error) in
            if let indexPathNew = indexPathh {
                DispatchQueue.main.async {
                    if let getCell = collectionView.cellForItem(at: indexPathNew) {
                        (getCell as? PicSumPhotosCell)!.imageView.image = image
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /* Reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
        if loadMore {return}
        let picSumElement = picSumPhotosModel[indexPath.row]
        ImageDownloadManager.shared.slowDownImageDownloadTaskfor(picSumElement)
    }
    
    // MARK: - Helper Method
    private func loadMorePhotos() {
        if !loadMore {
            loadMore = true
            vc?.pageNumber += 1
            if vc!.pageNumber < 6 { //allow only 5 pages result
                vc?.fetchPicSumPhotosList(page: vc!.pageNumber)
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension DashboardViewModel: UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // here you work out the total amount of space taken up by padding
        // there will be n + 1 evenly sized spaces, where n is the number of items in the row
        // the space size can be taken from the left section inset
        // subtracting this from the view's width and dividing by the number of items in a row gives you the width for each item
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = (vc?.view.frame.width)! - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        // return the size as a square
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // return the spacing between the cells, headers, and footers. Used a constant for that
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // controls the spacing between each line in the layout. this should be matched the padding at the left and right
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.loadMore {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: vc!.footerViewReuseIdentifier, for: indexPath) as! CustomFooterView
            vc?.footerView = aFooterView
            vc?.footerView?.backgroundColor = UIColor.clear
            return aFooterView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: vc!.footerViewReuseIdentifier, for: indexPath)
            return headerView
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            vc?.footerView?.prepareInitialAnimation()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            vc?.footerView?.stopAnimate()
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(abs(triggerThreshold),1.0);
        vc?.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            vc?.footerView?.animateFinal()
        }
        print("pullRatio:\(pullRatio)")
    }
    
    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = abs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight == 0.0
        {
            if (vc?.footerView?.isAnimatingFinal ?? false) {
                print("load more trigger")
                vc?.footerView?.startAnimate()
            }
        }
    }
}
