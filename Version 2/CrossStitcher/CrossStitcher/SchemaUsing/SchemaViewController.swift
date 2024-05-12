//
//  SchemaViewController.swift
//  ImagePuzzleViaCollectionView
//
//  Created by Valery Dubovoy on 19.08.2022.
//

import UIKit

let schemaViewOffset: CGFloat = 16

class SchemaViewController: UIViewController {
    
    var presenter: SchemaViewControllerPresenterProtocol!
    
    private var markerNumber: Int16 = 0 {
        willSet {
            presenter.setCurrentTool(newToolNumber: newValue)
        }
        didSet {
            marker1Button.isSelected = false
            marker2Button.isSelected = false
            eraseButton.isSelected = false
            switch presenter.currentTool {
                case .marker1:
                    marker1Button.isSelected = true
                case .marker2:
                    marker2Button.isSelected = true
                case .eraser:
                    eraseButton.isSelected = true
            }
        }
    }

    @IBOutlet weak var marker1Button: UIBarButtonItem!
    @IBOutlet weak var marker2Button: UIBarButtonItem!
    @IBOutlet weak var eraseButton: UIBarButtonItem!

    @IBOutlet weak var undoButton: UIBarButtonItem!
    
    @IBAction func marker1ColorChange(_ sender: UIBarButtonItem) {
        let colorPickerView = ViewsAssembler.createColorPickerView(color: self.presenter.markerColor1,
                                                                   alfa: self.presenter.alfaMarker1,
                                                                   sampleImage: self.presenter.schemaImage)
            {color,alfa in
                self.presenter.markerColor1 = color
                self.presenter.alfaMarker1 = alfa
                self.presenter.saveProperties()
                
                self.marker1Button.tintColor = color
                
                // make redraw cells with marker 1
                var paths = [IndexPath]()
                let markedElements = self.presenter.markers.filter { element in
                    element.value.marker == Tools.marker1.rawValue
                }
                for markerDescription in markedElements {
                    paths.append( IndexPath(row: Int(markerDescription.value.row * self.presenter.columns + markerDescription.value.column), section: 0))
                }
        
                self.schemaViaCollectionView?.updateCells(cells: paths)
            }
        self.present(colorPickerView, animated: true)
    }
    
    @IBAction func marker2ColorChange(_ sender: UIBarButtonItem) {
        let colorPickerView = ViewsAssembler.createColorPickerView(color: self.presenter.markerColor1,
                                                                   alfa: self.presenter.alfaMarker1,
                                                                   sampleImage: self.presenter.schemaImage)
            {color,alfa in
                self.presenter.markerColor1 = color
                self.presenter.alfaMarker1 = alfa
                self.presenter.saveProperties()
                
                self.marker1Button.tintColor = color
                
                // make redraw cells with marker 1
                var paths = [IndexPath]()
                let markedElements = self.presenter.markers.filter { element in
                    element.value.marker == Tools.marker1.rawValue
                }
                for markerDescription in markedElements {
                    paths.append( IndexPath(row: Int(markerDescription.value.row * self.presenter.columns + markerDescription.value.column), section: 0))
                }
        
                self.schemaViaCollectionView?.updateCells(cells: paths)
            }
        self.present(colorPickerView, animated: true)
    }
    
    @IBAction func makeMarker1AsMarker2(_ sender: UIBarButtonItem) {
        let changedIndexes = presenter.replaceMarker1ToMarker2()
        var paths = [IndexPath]()
        for cellIndex in changedIndexes {
            
            paths.append( getIndexPathFor(cellCoordinate: CellCoordinate(index: cellIndex) ) )
        }

        self.schemaViaCollectionView?.updateCells(cells: paths)
    }
    
    @IBAction func markerChoose(_ sender: UIBarButtonItem) {
        markerNumber = Int16(sender.tag)
    }
    
    @IBAction func undoButtonAction(_ sender: UIBarButtonItem) {
        let changedIndexes = presenter.undoAction()
        var paths = [IndexPath]()
        for cellIndex in changedIndexes {
            
            paths.append( getIndexPathFor(cellCoordinate: CellCoordinate(index: cellIndex) ) )
        }

        self.schemaViaCollectionView?.updateCells(cells: paths)
   }
    
    @IBAction func editStitchModel(_ sender: UIBarButtonItem) {
        // Create a reference to the the appropriate storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the desired view controller from the storyboard using the view controllers identifier
        // Cast is as the custom view controller type you created in order to access it's properties and methods
        let editor = storyboard.instantiateViewController(withIdentifier: "StitchEditorTableViewController") as!StitchEditorTableViewController
        
        //let editor = StitchEditorTableViewController()
        editor.modalPresentationStyle = .fullScreen
        let editorPresenter = StitchPresenter(view: editor, dbStitch: presenter.dbStitch, doAfterSave: {
            self.presenter.updateDataFromBase()
            //self.schemaViaCollectionView?.updateAll()
        })
        
        editor.presenter = editorPresenter
        //self.present(editor, animated: true)
        self.navigationController?.pushViewController(editor, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        markerNumber = presenter.currentTool.rawValue
        
        //set colors of marker buttons like marker color
        marker1Button.tintColor = presenter.markerColor1
        marker2Button.tintColor = presenter.markerColor2
        
        let schemaViaCollectionView = ImageViewAsCollectionView.init(frame: CGRect(x: 0, y: schemaViewOffset, width: view.frame.width, height: view.frame.height - schemaViewOffset))
        schemaViaCollectionView.delegete = self
        // set properties: image, rows, columns
        schemaViaCollectionView.startWith(presenter: self.presenter)
        schemaViaCollectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview( schemaViaCollectionView )
        self.schemaViaCollectionView = schemaViaCollectionView

        NSLayoutConstraint.activate([
            schemaViaCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: schemaViewOffset),
            schemaViaCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            schemaViaCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            schemaViaCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)])
        
        updateUndoButtonStatus()
    }
    
    weak var schemaViaCollectionView: ImageViewAsCollectionView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //schemaViaCollectionView.didChangeLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.saveProperties()
        
        // to avoid co-references. For example ImageViewAsCollectionView has got delegate reference to it view, but overwise it is in stack of subviews
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    /*
    @IBAction func dropMenuAction(_ sender: UIBarButtonItem) {
        let alertTitle = NSLocalizedString("Futures", comment: "")
        let alertMessage = NSLocalizedString("", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        if #available(iOS 16.0, *) {
            alert.popoverPresentationController?.sourceItem = sender
        } else {
            alert.popoverPresentationController?.barButtonItem = sender
        }
        // Replace marker1 to marker2
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Replace M1 with M2", comment: ""), style: .destructive, handler:
                { _ in
                    self.makeMarker1AsMarker2(sender)
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Change marker 1 color", comment: ""), style: .default, handler:
                            { _ in
                                let colorPickerView = ViewsAssembler.createColorPickerView(color: self.presenter.markerColor1,
                                                                                           alfa: self.presenter.alfaMarker1,
                                                                                           sampleImage: self.presenter.schemaImage)
                                    {color,alfa in
                                        //print("Choosen color \(color) with opacity \(alfa)")
                                        self.presenter.markerColor1 = color
                                        self.presenter.alfaMarker1 = alfa
                                        self.presenter.saveProperties()
                                        
                                        self.marker1Button.tintColor = color
                                        
                                        // make redraw cells with marker 1
                                        var paths = [IndexPath]()
                                        let markedElements = self.presenter.markers.filter { element in
                                            element.value.marker == Tools.marker1.rawValue
                                        }
                                        for markerDescription in markedElements {
                                            paths.append( IndexPath(row: Int(markerDescription.value.row * self.presenter.columns + markerDescription.value.column), section: 0))
                                        }
                                
                                        self.schemaViaCollectionView?.updateCells(cells: paths)
                                    }
                                //self.navigationController?.pushViewController(colorPickerView, animated: true)
                                self.present(colorPickerView, animated: true)

                            }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Change marker 2 color", comment: ""), style: .default, handler:
                            { _ in
                                let colorPickerView = ViewsAssembler.createColorPickerView(color: self.presenter.markerColor2,
                                                                                           alfa: self.presenter.alfaMarker2,
                                                                                           sampleImage: self.presenter.schemaImage)
                                    {color,alfa in
                                        //print("Choosen color \(color) with opacity \(alfa)")
                                        self.presenter.markerColor2 = color
                                        self.presenter.alfaMarker2 = alfa
                                        self.presenter.saveProperties()
                                        
                                        self.marker2Button.tintColor = color
                                        
                                        // make redraw cells with marker 2
                                        var paths = [IndexPath]()
                                        let markedElements = self.presenter.markers.filter { element in
                                            element.value.marker == Tools.marker2.rawValue
                                        }
                                        for markerDescription in markedElements {
                                            paths.append( IndexPath(row: Int(markerDescription.value.row * self.presenter.columns + markerDescription.value.column), section: 0))
                                        }
                                
                                        self.schemaViaCollectionView?.updateCells(cells: paths)
                                    }
                                //self.navigationController?.pushViewController(colorPickerView, animated: true)
                                self.present(colorPickerView, animated: true)

                            }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel))
        
        self.present(alert, animated: true, completion: nil)

}*/
    
}

// MARK: - Collection view Delegate
extension SchemaViewController: SchemaCollectionViewProtocol {
    
    func configureCell(cell: ImageCollectionViewCell, for indexPath: IndexPath) {
        // Configure the cell
        
        let coordinates = getCellCoordinatesFor(indexPath: indexPath)
        let cellDescription = presenter.getCellDescriptionFor(cellCoord: coordinates)
        cell.image = cellDescription.image
        
        if cellDescription.isMarked(), let color = cellDescription.markerColor {
            cell.setMarkerColor(color: color, alfa: cellDescription.markerAlfa)
        } else {
            cell.setMarkerColor(color: UIColor.black, alfa: 0.0)
        }
        //cell.label.text = "r:\(coordinates.section) c:\(coordinates.row)"
    }

    func didSelectCell(at indexPath: IndexPath) {
        let coordinates = getCellCoordinatesFor(indexPath: indexPath)

        _ = presenter.tapOnCellAt(cellCoord: coordinates)
        self.schemaViaCollectionView?.updateCells(cells: [indexPath])
    }
    
    // translates indexPath in collection view coordinates to indexPath as columns/rows coordinates
    private func getCellCoordinatesFor(indexPath: IndexPath) -> CellCoordinate {
        let row: Int = indexPath.row / Int(presenter.columns)
        let column: Int = indexPath.row % Int(presenter.columns)
        
        return CellCoordinate(row: row, column: column)
    }
    
    private func getIndexPathFor( cellCoordinate: CellCoordinate ) -> IndexPath {
        return IndexPath(row: cellCoordinate.row * Int(presenter.columns) + cellCoordinate.column, section: 0)
    }
    

}

extension SchemaViewController: SchemaViewControllerProtocol {
    
    func updateUndoButtonStatus() {
        undoButton.isEnabled = presenter.history.available
    }

}
