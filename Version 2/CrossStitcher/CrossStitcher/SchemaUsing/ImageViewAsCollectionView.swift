//
//  ImageViewAsCollectionView.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 19.08.2022.
//  Copyright © 2022 Nick Walter. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let interItemSpacing = CGFloat( 0.0 )
private let inter10ItemsSpacing = CGFloat( 9.0 )
private let itemInsets = CGFloat(1.0)

private let columnsMarksHeaderHeight: CGFloat = 50.0
private let rowsMarksHeaderWidth: CGFloat = 50.0

private let maxScale: CGFloat = 10.0
private let minScale: CGFloat = 0.2

class ImageViewAsCollectionView: UIView {

    //var stitchModel: StitchModel!
    
    // public API
    var image = UIImage(named: "Example")
    var rows = 27
    var columns = 23
    
    var scale:CGFloat = 1.0 {
        didSet {
            if scale > maxScale {
                scale = oldValue
            } else if scale < minScale {
                scale = oldValue
            }
            
            if oldValue != scale {
                collectionView.collectionViewLayout = createSchemaLayout()
            }
        }
    }
    
    var delegete: SchemaCollectionViewDelegate?
    
    // private
    
    // for pinch gesture
    private var startPinchScale: CGFloat = 0.0
    
    func startWith(stitchModel: StitchModel) {
        image = stitchModel.getSchemaImage()
        rows = Int( stitchModel.getRows() )
        columns = Int( stitchModel.getColumns() )
        
        initRowsLabels()
        initColumnsLabels()
        
        // gestures
        let pinchGestureRecognizer = UIPinchGestureRecognizer(
                    target: self,
                    action: #selector(self.pinchGestureHandler(recognizer:))
            )
        self.addGestureRecognizer( pinchGestureRecognizer )

    }
    
    func didChangeLayout() {
        rearrangeLabels()
    }

    var cellHeight: CGFloat { return (image?.size.height ?? 0.0) / CGFloat(rows) * scale}
    var cellWidth: CGFloat { return (image?.size.width ?? 0.0) / CGFloat(columns) * scale}

    private lazy var collectionView: UICollectionView = {
        let cvFrame = CGRect(x: rowsMarksHeaderWidth,
                             y: columnsMarksHeaderHeight,
                             width: self.bounds.width - rowsMarksHeaderWidth,
                             height: self.bounds.height - columnsMarksHeaderHeight)
        
        let cv = UICollectionView.init(frame: cvFrame, collectionViewLayout: createSchemaLayout())
        cv.dataSource = self
        cv.delegate = self
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cv)

        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: self.topAnchor, constant: columnsMarksHeaderHeight),
            cv.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: rowsMarksHeaderWidth),
            cv.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cv.trailingAnchor.constraint(equalTo: self.trailingAnchor)])
        
        cv.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        return cv
    }()
    
    private var columsLabels = [UILabel]()
    private var rowsLabels = [UILabel]()
    private var contentOffset = CGPoint.zero

    
}

extension ImageViewAsCollectionView {
    // MARK: CollectionViewLayout
    
    func createSchemaLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute( cellWidth ),
                                             heightDimension: .absolute(cellHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInsets, leading: itemInsets, bottom: itemInsets, trailing: itemInsets)
                
        let tenColumnsCount: Int = columns / 10
        let restColumnsCount: Int = columns % 10
        
        var restHorizontalGroup: NSCollectionLayoutGroup?

        if restColumnsCount > 0 {
            let restHorizontalGroupSize = NSCollectionLayoutSize(widthDimension: .absolute((cellWidth + interItemSpacing ) * CGFloat(restColumnsCount) ),
                                                   heightDimension: .absolute(cellHeight))
            restHorizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: restHorizontalGroupSize, subitem: item, count: restColumnsCount)
            restHorizontalGroup?.interItemSpacing = .fixed( interItemSpacing )
        }
    
        var horizontalGroup: NSCollectionLayoutGroup?
        var horizontalSize: CGFloat = 0.0
        
        if tenColumnsCount > 0 {
            // group of 10 items
            horizontalSize = 10.0 * (cellWidth + interItemSpacing)
            
            var groupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                   heightDimension: .absolute(cellHeight))
            horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 10)
            horizontalGroup?.interItemSpacing = .fixed( interItemSpacing )
            
            // join 10 items' groups into one group
            horizontalSize = ( horizontalSize + inter10ItemsSpacing ) * CGFloat( tenColumnsCount )
            groupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                   heightDimension: .absolute(cellHeight))
            horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: horizontalGroup!, count: tenColumnsCount)
            horizontalGroup?.interItemSpacing = .fixed( inter10ItemsSpacing )
            
            if restColumnsCount > 0 {
                // add rest columns over 10 items block
                horizontalSize += (cellWidth + interItemSpacing) * CGFloat( restColumnsCount ) + inter10ItemsSpacing
                groupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                       heightDimension: .absolute(cellHeight))
                horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [horizontalGroup!, restHorizontalGroup!])

                horizontalGroup?.interItemSpacing = .fixed( inter10ItemsSpacing )
            }
            
        } else {
            horizontalGroup = restHorizontalGroup
            horizontalSize = (cellWidth + interItemSpacing ) * CGFloat(restColumnsCount)
        }
      
        let tenRowsCount: Int = rows / 10
        let restRowsCount: Int = rows % 10

        var restVerticalGroup: NSCollectionLayoutGroup?

        if restRowsCount > 0 {
            let restVerticalGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                   heightDimension: .absolute((cellHeight + interItemSpacing) * CGFloat( restRowsCount)))
            restVerticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: restVerticalGroupSize, subitem: horizontalGroup!, count: restRowsCount)
            restVerticalGroup?.interItemSpacing = .fixed( interItemSpacing )
        }

        var verticalGroup: NSCollectionLayoutGroup?
        var verticalSize: CGFloat = 0.0
        
        if tenRowsCount > 0 {
            // 10 rows' block
            verticalSize = 10.0 * (cellHeight + interItemSpacing)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                   heightDimension: .absolute(verticalSize))
            verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: horizontalGroup!, count: 10)
            verticalGroup?.interItemSpacing = .fixed( interItemSpacing )
            
        } else {
            verticalGroup = restVerticalGroup
        }


        let section = NSCollectionLayoutSection(group: verticalGroup!)
        section.interGroupSpacing = inter10ItemsSpacing

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ImageViewAsCollectionView: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 //rows
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return columns * rows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell
        if let d = delegete {
            d.configureCell(cell: cell, for: indexPath)
        }
    
        return cell
    }
    
}

extension ImageViewAsCollectionView: UICollectionViewDelegate {
    // MARK: ScrollVew Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        rearrangeLabels()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let d = delegete {
            d.didSelectCell(at: indexPath)
        }
        // redraw the cell
        collectionView.reconfigureItems(at: [indexPath])
    }
}

extension ImageViewAsCollectionView {
    // MARK: grid LABELS
    
    //var startCoordinateForRowsLabels = CGPoint(x: 55, y: 55)
    //var startCoordinateForColumnsLabels = CGPoint(x: 55, y: 155)

    private func initColumnsLabels() {
        // remove old labels
        for label in columsLabels {
            label.removeFromSuperview()
        }
        
        columsLabels = []
        
        for column in 1...columns/10 {
            
            let newLabel = UILabel(frame: CGRect())
            self.addSubview(newLabel)
            newLabel.text = "\(column * 10)"
            newLabel.sizeToFit()
            setCenterForColumnLabel(newLabel, inColumn: column)
            
            columsLabels.append(newLabel)
        }
    }
    
    private func initRowsLabels() {
        // remove old labels
        for label in rowsLabels {
           label.removeFromSuperview()
        }
        rowsLabels = []
        for row in 1...rows/10 {
            
            let newLabel = UILabel(frame: CGRect())
            self.addSubview(newLabel)
            newLabel.text = "\(row * 10)"
            newLabel.sizeToFit()
            setCenterForRowLabel(newLabel, inRow: row)
            
            rowsLabels.append(newLabel)
        }
    }
    
    private func rearrangeLabels() {
        for column in 1...columns/10 {
            let newLabel = columsLabels[column - 1]
            setCenterForColumnLabel(newLabel, inColumn: column)
        }
        
        for row in 1...rows/10 {
            let newLabel = rowsLabels[row - 1]
            setCenterForRowLabel(newLabel, inRow: row)
        }
    }
    
    private func setCenterForRowLabel( _ label: UILabel, inRow row: Int ){
        label.center = CGPoint(x: xPointForRowLabel( label ), y: yPointForRowLabel(inRow: row * 10) )
    }
    
    private func setCenterForColumnLabel( _ label: UILabel, inColumn column: Int ) {
        label.center = CGPoint(x: xPointForColumnLabel(inColumn: column * 10), y: yPointForColumnLabel( label ))
    }
    
    private func xPointForRowLabel(_ label: UILabel ) -> CGFloat {
        return collectionView.frame.origin.x - 5 - label.frame.size.width / 2
    }

    private func yPointForRowLabel( inRow row: Int ) -> CGFloat {
        return collectionView.frame.origin.y + yFor(row: row) - contentOffset.y
    }

    private func xPointForColumnLabel( inColumn column: Int ) -> CGFloat {
        return collectionView.frame.origin.x + xFor(column: column) - contentOffset.x
    }

    private func yPointForColumnLabel(_ label: UILabel ) -> CGFloat {
        return collectionView.frame.origin.y - 5 - label.frame.size.height / 2
    }

    private func yFor( row: Int ) -> CGFloat {
        let blocks: Int = row / 10
        return ( cellHeight + interItemSpacing ) * CGFloat( row ) + CGFloat( blocks ) * inter10ItemsSpacing
    }

    private func xFor( column: Int ) -> CGFloat {
        let blocks: Int = column / 10
        return ( cellWidth + interItemSpacing ) * CGFloat( column ) + CGFloat( blocks ) * inter10ItemsSpacing
    }
}

extension ImageViewAsCollectionView: UIGestureRecognizerDelegate {
    // MARK: Gesture handlers
    
    // change zoom scale
    @objc func pinchGestureHandler( recognizer: UIPinchGestureRecognizer ) {
        guard recognizer.view != nil else {return}
        
        switch recognizer.state {
            case .began:
                // Save the view's original position.
                startPinchScale = scale
            case .cancelled:
                scale = startPinchScale
            case .changed: fallthrough    //"fallthrough" = выполнить код для следующего case (можно так же писать "case .changed, .ended:" )
            case .ended:
                scale = startPinchScale * recognizer.scale
            default: break
        }
    }
}
