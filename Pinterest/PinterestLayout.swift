//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by Kan Chen on 1/6/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
  func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth: CGFloat) -> CGFloat
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width:CGFloat) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  var photoHeight: CGFloat = 0

  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }

  override func isEqual(object: AnyObject?) -> Bool {
    if let attributes = object as? PinterestLayoutAttributes {
      if attributes.photoHeight == photoHeight {
        return super.isEqual(object)
      }
    }
    return false
  }
}

class PinterestLayout: UICollectionViewLayout {
  var delegate: PinterestLayoutDelegate!

  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  private var cacheHeadAttributes = [UICollectionViewLayoutAttributes]()
  private var cache = [PinterestLayoutAttributes]()

  private var contentHeight:CGFloat = 0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
  }

  override func prepareLayout() {
    if cache.isEmpty {
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset = [CGFloat]()
      for column in 0..<numberOfColumns {
        xOffset.append( CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)

      for item in 0..<collectionView!.numberOfItemsInSection(0) {
        let indexPath = NSIndexPath(forItem: item, inSection: 0)

        let width = columnWidth - cellPadding * 2
        let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)

        let height = cellPadding * 2 + photoHeight + annotationHeight

        if indexPath.item == 0 {
          let titleAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
          titleAttributes.frame = CGRect(x: 0, y: yOffset[column], width: contentWidth, height: 60)
          titleAttributes.zIndex = 10
          cacheHeadAttributes.append(titleAttributes)
          for col in 0..<yOffset.count {
            yOffset[col] += 60
          }
        }

        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        let insetFrame = CGRectInset(frame, cellPadding, cellPadding)

        let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.photoHeight = photoHeight
        attributes.frame = insetFrame
        cache.append(attributes)

        contentHeight = max(contentHeight, CGRectGetMaxY(frame))
        yOffset[column] = yOffset[column] + height

        column = column >= (numberOfColumns - 1) ? 0 : ++column

      }
    }
  }

  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()

    for attributes in cache {
      if CGRectIntersectsRect(attributes.frame, rect) {
        layoutAttributes.append(attributes)
      }
    }

    for attributes in cacheHeadAttributes {
      if CGRectIntersectsRect(attributes.frame, rect) {
        layoutAttributes.append(attributes)
      }
    }
    print("Attributes count: \(layoutAttributes.count) in Rect: \(rect)")
    return layoutAttributes
  }

  override class func layoutAttributesClass() -> AnyClass {
    return PinterestLayoutAttributes.self
  }
}
