//
//  SchemaViewController.swift
//  ImagePuzzleViaCollectionView
//
//  Created by Valery Dubovoy on 19.08.2022.
//

import UIKit

let schemaViewOffset: CGFloat = 40

class SchemaViewController: UIViewController {
    
    var stitchModel: StitchModel!
    
    var schemaViaCollectionView: ImageViewAsCollectionView!
    
    private var image: UIImage?
    private var rows: Int = 0
    private var columns: Int = 0
    
    private var markerNumber = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        image = stitchModel.getSchemaImage()
        rows = Int( stitchModel.getRows() )
        columns = Int( stitchModel.getColumns() )

        
        schemaViaCollectionView = ImageViewAsCollectionView.init(frame: CGRect(x: 0, y: schemaViewOffset, width: view.frame.width, height: view.frame.height - schemaViewOffset))
        schemaViaCollectionView.delegete = self
        // set properties: image, rows, columns
        schemaViaCollectionView.startWith(stitchModel: stitchModel)
        
        schemaViaCollectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview( schemaViaCollectionView )

        NSLayoutConstraint.activate([
            schemaViaCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: schemaViewOffset),
            schemaViaCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            schemaViaCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            schemaViaCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        schemaViaCollectionView.didChangeLayout()
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

extension SchemaViewController: SchemaCollectionViewDelegate {
    func configureCell(cell: ImageCollectionViewCell, for indexPath: IndexPath) {
        // Configure the cell
        let coordinates = getCellCoordinatesFor(indexPath: indexPath)
        let cellDescription = stitchModel.getCellDescription(at: coordinates)
        cell.image = cellDescription.image
        
        if cellDescription.isMarked, let color = cellDescription.markerColor {
            cell.setMarkerColor(color: color, alfa: 0.5)
        } else {
            cell.setMarkerColor(color: UIColor.black, alfa: 0.0)
        }
        //cell.label.text = "r:\(coordinates.section) c:\(coordinates.row)"
        cell.backgroundColor = UIColor.red
    }
    
    func didSelectCell(at indexPath: IndexPath) {
        let coordinates = getCellCoordinatesFor(indexPath: indexPath)
        stitchModel.toggleMarkerAt(row: coordinates.row, column: coordinates.section, with: 1)
    }
    
    // translates indexPath in collection view coordinates to indexPath as columns/rows coordinates
    private func getCellCoordinatesFor(indexPath: IndexPath) -> IndexPath {
        let row: Int = indexPath.row / columns
        let column: Int = indexPath.row % columns
        
        return IndexPath(row: row, section: column)
    }
    

}
