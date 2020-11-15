//
//  crossStitchViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 11/05/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit

class crossStitchViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    // MARK: controller Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       /* let objectToOpen = CrossStitchObject()//(withImage: UIImage(named: "testImage"))
        objectToOpen.schemaImage = UIImage(named: "testImage")
        objectToOpen.rows = 30
        objectToOpen.columns = 40
        objectToOpen.gridRect = CGRect(x: 0, y: 0, width: objectToOpen.imageSize.width, height: objectToOpen.imageSize.height)

        crossStitchObject = objectToOpen
        */
        if csDBObject != nil {
            crossStitchObject = csDBObject!.getCrossStitchObject()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if csDBObject != nil {
            self.rearrangeLabels()
        }
    }
    
    var csDBObject: CrossStitch?
    
    private var crossStitchObject = CrossStitchObject() {
        didSet {
            let csObj = self.crossStitchObject
                zoomableImageView.gridRect = csObj.gridRect
                zoomableImageView.rows = csObj.rows
                zoomableImageView.columns = csObj.columns

                if let sImage = csObj.schemaImage {
                    image = sImage
                }
            
            if gridScrollView != nil {
                initColumnsLabels()
                initRowsLabels()

            }
        }
    }
    
    private var modified = false

    // MARK: scroll & zoom
    @IBOutlet weak var gridScrollView: UIScrollView!{
        didSet {
            gridScrollView.addSubview(zoomableImageView)
            gridScrollView.delegate = self
        }
    }
    
    @IBOutlet var mainVew: UIView!
    @IBOutlet weak var frameView: CrossStitchView!
    
    // Delegate for zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomableImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == gridScrollView {
            //print("scale for image \(scrollView.zoomScale)")
            zoomableImageView.zoomScale = scrollView.zoomScale
            
            rearrangeLabels()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == gridScrollView {
            //print("frame for image \(scrollView.contentOffset)")
            zoomableImageView.contentOffset = scrollView.contentOffset
            
            rearrangeLabels()
            setLowerRightHolderPosition()
            setUpperLeftHolderPosition()
        }
    }
    
    lazy var zoomableImageView = GridOverImageView()
    private var image: UIImage? {
        get {
            return zoomableImageView.image
        }
        set {
            zoomableImageView.image = newValue
            zoomableImageView.sizeToFit()   // изменить размер imageView по размеру картинки
            
            // Обязательно установить размер канвы
            gridScrollView?.contentSize = zoomableImageView.originalSize //.frame.size
        }
    }
    
    private var gridRect: CGRect {
        get {
            return crossStitchObject.gridRect
        }
        set {
            crossStitchObject.gridRect = newValue
            zoomableImageView.gridRect = newValue
            rearrangeLabels()
        }
    }

    // MARK: grid LABELS
    var columsLabels = [UILabel]()
    var rowsLabels = [UILabel]()
    
    //var startCoordinateForRowsLabels = CGPoint(x: 55, y: 55)
    //var startCoordinateForColumnsLabels = CGPoint(x: 55, y: 155)

    private func initColumnsLabels() {
        // remove old labels
        for label in columsLabels {
            label.removeFromSuperview()
        }
        
        columsLabels = []
        
        let columns = crossStitchObject.columns
            for column in 1...columns/10 {
                
                let newLabel = UILabel(frame: CGRect())
                frameView?.addSubview(newLabel)
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
        let rows = crossStitchObject.rows
            for row in 1...rows/10 {
                
                let newLabel = UILabel(frame: CGRect())
                frameView?.addSubview(newLabel)
                newLabel.text = "\(row * 10)"
                newLabel.sizeToFit()
                setCenterForRowLabel(newLabel, inRow: row)
                
                rowsLabels.append(newLabel)
            }
    }
    
    private func rearrangeLabels() {
        let columns = crossStitchObject.columns
            for column in 1...columns/10 {
                let newLabel = columsLabels[column - 1]
                setCenterForColumnLabel(newLabel, inColumn: column)
            }
        
        let rows = crossStitchObject.rows
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
        return gridScrollView.frame.origin.x - 5 - label.frame.size.width / 2
    }

    private func yPointForRowLabel( inRow row: Int ) -> CGFloat {
        return gridScrollView.frame.origin.y + zoomableImageView.yForRow(row: row) - zoomableImageView.contentOffset.y
    }

    private func xPointForColumnLabel( inColumn column: Int ) -> CGFloat {
        return gridScrollView.frame.origin.x + zoomableImageView.xForColumn(column: column) - zoomableImageView.contentOffset.x
    }

    private func yPointForColumnLabel(_ label: UILabel ) -> CGFloat {
        return gridScrollView.frame.origin.y - 5 - label.frame.size.height / 2
    }

    // MARK: controller MODE
    
    var mode = vcMode.scene
    
    @IBOutlet weak var modeSwitchSegmentControl: UISegmentedControl! {
        didSet{
            modeSwitchSegmentControl.selectedSegmentIndex = self.mode.rawValue
        }
    }
    
    @IBAction func modeSwitchAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: mode = .scene
            case 1: mode = .grid
            case 2: mode = .marker1
            case 3: mode = .marker2
            default: break
        }
        changeMode()
    }
    
    func changeMode() {
        switch mode {
        case .scene:
            removeGridHolders()
        case .grid:
            setGridHolders()
        case .marker1:
            removeGridHolders()
        case .marker2:
            removeGridHolders()
        }
    }

    // MARK: grid HOLDERS
    
    private func setGridHolders() {
        upperLeftHolder = cornerHolderView()
        lowerRightHolder = cornerHolderView()
    }
    
    private func removeGridHolders() {
        if let holder = upperLeftHolder{
            holder.removeFromSuperview()
        }
        if let holder = lowerRightHolder{
            holder.removeFromSuperview()
        }
        upperLeftHolder = nil
        lowerRightHolder = nil
    }
    
    var upperLeftHolder: cornerHolderView? {
        didSet{
            if let holder = self.upperLeftHolder {
                gridScrollView.addSubview( holder )
                setUpperLeftHolderPosition()

                let panGestureRecognizer = UIPanGestureRecognizer(
                            target: self,
                            action: #selector(self.gridHolderPanGestureHandler(recognizer:))
                    )
                holder.addGestureRecognizer( panGestureRecognizer )
            }
        }
    }
            
    var lowerRightHolder: cornerHolderView? {
        didSet{
            if let holder = self.lowerRightHolder {
                gridScrollView.addSubview( holder )
                setLowerRightHolderPosition()

                let panGestureRecognizer = UIPanGestureRecognizer(
                            target: self,
                            action: #selector(self.gridHolderPanGestureHandler(recognizer:))
                    )
                holder.addGestureRecognizer( panGestureRecognizer )
            }
        }
    }
    
    private func setUpperLeftHolderPosition() {
        if let holder = self.upperLeftHolder {
            holder.center = zoomableImageView.convertToScreenCoordinates(forPoint: gridRect.origin)
        }
    }
    
    private func setLowerRightHolderPosition() {
        if let holder = self.lowerRightHolder {
            holder.center = zoomableImageView.convertToScreenCoordinates(forPoint: CGPoint(x: gridRect.maxX, y: gridRect.maxY) )
        }
    }
    
    private var initialCenter = CGPoint(x: 0, y: 0)       // to save corner initial position before its start moving

    @objc func gridHolderPanGestureHandler( recognizer: UIPanGestureRecognizer ) {
        guard recognizer.view != nil else {return}
        let holder = recognizer.view!
        
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = recognizer.translation(in: holder.superview)
        
        switch recognizer.state {
            case .began:
                // Save the view's original position.
                self.initialCenter = holder.center
        case .cancelled:
            holder.center = self.initialCenter
            case .changed: fallthrough    //"fallthrough" = выполнить код для следующего case (можно так же писать "case .changed, .ended:" )
            case .ended:
                //обновить координаты центра holder в соответствии с координатами жеста translation.x, translation.y в системе координат superview
                // Add the X and Y translation to the view's original position.
                let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
                holder.center = newCenter
                //recognizer.setTranslation(CGPoint.zero, in: holder)
            default: break
        }
        
        if let startScreenPoint = upperLeftHolder?.center, let endScreenPoint = lowerRightHolder?.center {
            let startPoint = zoomableImageView.convertToOriginCoordinates(forScreenPoint: startScreenPoint)
            let endPoint = zoomableImageView.convertToOriginCoordinates(forScreenPoint: endScreenPoint)
            let newRect = CGRect(x: startPoint.x,
                                 y: startPoint.y,
                                 width: (endPoint.x - startPoint.x),
                                 height: (endPoint.y - startPoint.y))
            self.gridRect = newRect
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

enum vcMode: Int {
    case scene = 0
    case grid = 1
    case marker1 = 2
    case marker2 = 3
    
    // добавим все варианты в массив
    static var all = [vcMode.scene, .grid, .marker1, .marker2]
}
