//
//  crossStitchViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 11/05/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit
//import Foundation

class crossStitchViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, SwiftColorPickerDelegate {
    

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
        
    override func viewWillDisappear(_ animated: Bool) {
        // перед закрытием окна сохраним изменения
        csDBObject?.updateFromCrossStitchObject(crossStitchObject, inViewContorller: self)
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        markedCellsCache = [:]
        pannedCells = [:]
        csDBObject?.updateFromCrossStitchObject(crossStitchObject, inViewContorller: self)
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
            zoomableImageView.marker1Color = csObj.marker1Color
            zoomableImageView.marker2Color = csObj.marker2Color
            zoomableImageView.lineColor = csObj.gridColor

            
            zoomableImageView.markedCells = convertStringMarkersToDictionary(stringMarkers: csObj.markedCells)
            
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
    
    var mode = vcMode.scene {
        didSet{
            endMarkerMode()
            removeGridHolders()

            switch mode {
            case .scene:
                break
            case .grid:
                setGridHolders()
            case .marker1:
                startMarkerMode()
            case .marker2:
                startMarkerMode()
            }
        }
    }
    
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
            let pointForHolder = CGPoint(x: max( min(gridRect.minX, zoomableImageView.originalSize.width), 0),
                                         y: max( min( gridRect.minY, zoomableImageView.originalSize.height), 0))
            
            holder.center = zoomableImageView.convertToScreenCoordinates(forPoint: pointForHolder)
        }
    }
    
    private func setLowerRightHolderPosition() {
        if let holder = self.lowerRightHolder {
            let pointForHolder = CGPoint(x: max( min(gridRect.maxX, zoomableImageView.originalSize.width), 0),
                                         y: max( min( gridRect.maxY, zoomableImageView.originalSize.height), 0))

            holder.center = zoomableImageView.convertToScreenCoordinates(forPoint: pointForHolder )
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
    
    // MARK: - Marker mode
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    private func startMarkerMode() {
        panGestureRecognizer = UIPanGestureRecognizer(
                    target: self,
                    action: #selector(self.markerModePanGestureHandler)
            )
        panGestureRecognizer?.maximumNumberOfTouches = 1
        gridScrollView.addGestureRecognizer( panGestureRecognizer! )
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.markerModeTapGestureHandler))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        
        gridScrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func endMarkerMode() {
        if gridScrollView.gestureRecognizers != nil {
            for gesture in gridScrollView.gestureRecognizers! {
                if gesture.isKind(of: UITapGestureRecognizer.self) {
                    gridScrollView.removeGestureRecognizer(gesture)
                } else if gesture == panGestureRecognizer {
                    gridScrollView.removeGestureRecognizer(gesture)
                    panGestureRecognizer = nil
                }
            }

        }
    }
    
    
    func convertMakersToString() -> String {
        let encoder = JSONEncoder()
        //encoder.outputFormatting = .prettyPrinted

        let data = try? encoder.encode(zoomableImageView.markedCells)
        if data != nil {
            return String(data: data!, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
    
    func convertStringMarkersToDictionary(stringMarkers: String?) -> [GridCell: Int] {
        let emptyResult :[GridCell: Int] = [:]
        
        if stringMarkers == nil {
            return emptyResult
        }
        
        let decoder = JSONDecoder()
        if let decodableString = stringMarkers!.data(using: .utf8) {
            let dict = try? decoder.decode([GridCell: Int].self, from: decodableString)
            
            return  dict ?? emptyResult
        }
        return emptyResult
    }

    // MARK: - Tap gesture in Mark mode
    @objc func markerModeTapGestureHandler( recognizer: UITapGestureRecognizer ) {
        if recognizer.state == .ended {
            let pointOfTap = recognizer.location(in: zoomableImageView)
            let cell = zoomableImageView.cellForPoint(point: pointOfTap)
            zoomableImageView.changeMark(atCell: cell, withMark: self.mode == .marker1 ? 1 : 2)
            print("cell \(cell)")
            
            crossStitchObject.markedCells = convertMakersToString()
        }
    }
    
    // MARK: - Pan festure in Mark mode
    
    var pannedCells: [GridCell: Int?] = [:]   //будем запоминать ячейки и их отметки, чтобы их туда-сюда не красить пока чрез нее движемся
    var timerForPanService: Timer?
    var markedCellsCache: [GridCell: Int] = [:] // будем кэшировать изменения, чтобы уменьшить количество отрисовок. По таймеру выкладывать кэш
    
    @objc func markerModePanGestureHandler( recognizer: UIPanGestureRecognizer ) {
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        if recognizer.numberOfTouches != 1 {
            return
        }
        //остановим текущий таймер, если действия происходят очень быстро
        stopTimerForPanService()
        
        let pointOfTap = recognizer.location(in: zoomableImageView)
        //print("Point \(pointOfTap) at \(Date())")

        switch recognizer.state {
            case .cancelled:
                print("state = cancel")
                // отменить все выделения?
                for keyAndValue in pannedCells {
                    zoomableImageView.setMarkValue(forCell: keyAndValue.key, withMark: keyAndValue.value)
                }
                //очистим буфер
                pannedCells = [:]
 
            case .began:
                // готовим буфер
                pannedCells = [:]
                markedCellsCache = zoomableImageView.markedCells
                fallthrough    //"fallthrough" = выполнить код для следующего case (можно так же писать "case .changed, .ended:" )
            case .changed:
                fallthrough    //"fallthrough" = выполнить код для следующего case (можно так же писать "case .changed, .ended:" )
            case .ended:
                //определить по координатам ячейку и установить отметку
                let cell = zoomableImageView.cellForPoint(point: pointOfTap)
                if self.pannedCells[cell] == nil {
                    print("cell \(cell)")
                    // has not panned yet
                    // so add to list of panned
                    self.pannedCells[cell] = markedCellsCache[cell]
                    // and change mark
                    changeMark(atCell: cell, withMark: self.mode == .marker1 ? 1 : 2)
                }
                // стартуем таймер
                startTimerForPanService()
                break
            default: break
        }
    }
  
    func changeMark(atCell cell: GridCell, withMark mark: Int) {
        if markedCellsCache[cell] != mark {
            markedCellsCache[cell] = mark
        } else {
            markedCellsCache.removeValue(forKey: cell)
        }
    }

    func stopTimerForPanService() {
        if let _ = timerForPanService {
            timerForPanService?.invalidate()
            timerForPanService = nil
        }
    }
    
    func startTimerForPanService() {
        if timerForPanService == nil {
            timerForPanService = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (withTimer) in
                //print("global saving")
                self.zoomableImageView.markedCells = self.markedCellsCache
                self.stopTimerForPanService()
                self.crossStitchObject.markedCells = self.convertMakersToString()
            })
        } else {
            timerForPanService?.fire()
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

    var colorForMarker: Int = 0

    // MARK: - Settings
    // Delegate for Color Picker
    func colorSelectionChanged(selectedColor color: UIColor) {
        if colorForMarker == 1 {
            crossStitchObject.marker1Color = color
            zoomableImageView.marker1Color = color}
        else if colorForMarker == 2 {
            crossStitchObject.marker2Color = color
            zoomableImageView.marker2Color = color}
        else if colorForMarker == 3 {
            crossStitchObject.gridColor = color
            zoomableImageView.lineColor = color}
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        let alertTitle = NSLocalizedString("Settings", comment: "")
        let alertMessage = NSLocalizedString("", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        //alert.popoverPresentationController?.sourceRect = sender.frame

        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Choose marker 1 Color", comment: ""), style: .default, handler:
                { _ in
                    self.colorForMarker = 1
                    self.startGettingColor(sender: sender)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Choose marker 2 Color", comment: ""), style: .default, handler:
                { _ in
                    self.colorForMarker = 2
                    self.startGettingColor(sender: sender)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Choose grid line Color", comment: ""), style: .default, handler:
                { _ in
                    self.colorForMarker = 3
                    self.startGettingColor(sender: sender)
                }
            )
        )

        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Clear marker 1", comment: ""), style: .default, handler:
                { _ in
                    self.markedCellsCache = self.zoomableImageView.markedCells
                    self.markedCellsCache = self.markedCellsCache.filter({ (key: GridCell, value: Int) -> Bool in
                        value != 1
                    })
                    self.zoomableImageView.markedCells = self.markedCellsCache
                    self.crossStitchObject.markedCells = self.convertMakersToString()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Clear marker 2", comment: ""), style: .default, handler:
                { _ in
                    self.markedCellsCache = self.zoomableImageView.markedCells
                    self.markedCellsCache = self.markedCellsCache.filter({ (key: GridCell, value: Int) -> Bool in
                        value != 2
                    })
                    self.zoomableImageView.markedCells = self.markedCellsCache
                    self.crossStitchObject.markedCells = self.convertMakersToString()
                }
            )
        )

        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: nil)
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func startGettingColor(sender: UIButton) {
        let colorPickerVC = SwiftColorPickerViewController()
        
        colorPickerVC.delegate = self
        //colorPickerVC.dataSource = self
        colorPickerVC.modalPresentationStyle = .popover
        let popVC = colorPickerVC.popoverPresentationController!;
        popVC.sourceRect = sender.frame
        popVC.sourceView = self.view
        popVC.permittedArrowDirections = .any;
        popVC.delegate = self as? UIPopoverPresentationControllerDelegate;
        
        self.present(colorPickerVC, animated: true, completion: {
            // print("Reade<");
        })
    }
    
 }

enum vcMode: Int {
    case scene = 0
    case grid = 1
    case marker1 = 2
    case marker2 = 3
    
    // добавим все варианты в массив
    static var all = [vcMode.scene, .grid, .marker1, .marker2]
}
