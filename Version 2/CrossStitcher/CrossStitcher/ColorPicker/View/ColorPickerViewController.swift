//
//  ColorPickerViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 25.02.2024.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    var presenter: ColorPickerPresenterProtocol!
    /*
    private let reds = [0xEE, 0xCC, 0xAA, 0x88, 0x66, 0x44, 0x22, 0x00, 0xFF, 0xDD, 0xBB, 0x99, 0x77, 0x55, 0x33, 0x11]
    private let greens = [0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]
    private let blues = [0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]
     */
    private let reds = [0xCC, 0x66, 0x00, 0xFF, 0x99, 0x33]
    private let greens = [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]//[0x00, 0x22, 0x44, 0x66, 0x88, 0xAA, 0xCC, 0xFF]
    private let blues = [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]//[0x00, 0x22, 0x44, 0x66, 0x88, 0xAA, 0xCC, 0xFF]
     

    override func viewDidLoad() {
        super.viewDidLoad()

        self.colorCollection.collectionViewLayout = createLayout()
        self.colorCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        presenter.viewDidLoad()
    }


    @IBAction func savePressed(_ sender: Any) {
        presenter.doneAction(self.colorView.backgroundColor ?? Constants.marker1Color(), CGFloat( self.alfaSlider.value))
        if let rootVC = presentingViewController {
            rootVC.dismiss(animated: true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        if let rootVC = presentingViewController {
            rootVC.dismiss(animated: true)
        }
    }
 
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alfaSlider: UISlider!
    
    @IBAction func alfaSliderChanged(_ sender: UISlider) {
        presenter.choose(alfa:CGFloat(sender.value))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: CollectionViewLayout
    
    private let cellSize = CGFloat(32)
    private let itemInsets = CGFloat(1.0)
    private let interItemSpacing = CGFloat( 0.0 )
    private let inter10ItemsSpacing = CGFloat( 9.0 )
    private var vItemsCount: Int { return blues.count * 2 }
    private var hItemsCount: Int { reds.count / 2 * greens.count }

    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute( cellSize ),
                                             heightDimension: .absolute(cellSize))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInsets, leading: itemInsets, bottom: itemInsets, trailing: itemInsets)
                
        var horizontalGroup: NSCollectionLayoutGroup?
        let horizontalSize: CGFloat = (cellSize + interItemSpacing) * CGFloat( hItemsCount )
        
        let hGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                                   heightDimension: .absolute(cellSize))
        horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize:hGroupSize, subitem: item, count: hItemsCount)
        horizontalGroup?.interItemSpacing = .fixed( interItemSpacing )
      
        var verticalGroup: NSCollectionLayoutGroup?
        let verticalSize: CGFloat = (cellSize + interItemSpacing) * CGFloat( vItemsCount )
        
            
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(horizontalSize),
                                               heightDimension: .absolute(verticalSize))
        verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: horizontalGroup!, count: vItemsCount)
        verticalGroup?.interItemSpacing = .fixed( interItemSpacing )
            
        let section = NSCollectionLayoutSection(group: verticalGroup!)
        section.interGroupSpacing = inter10ItemsSpacing

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}

extension ColorPickerViewController: ColorPickerViewProtocol {
    func setAlfa(with alfa: CGFloat) {
        self.colorView.alpha = alfa
        alfaSlider.value = Float(alfa)
    }
    
    func setSampleImage(with image: UIImage?) {
        self.imageView.image = image
    }
    
    func setCurrentColor(with color: UIColor) {
        self.colorView.backgroundColor = color
    }
    
    
}

extension ColorPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.choose(color: colorFor(indexPath: indexPath))
    }
}

extension ColorPickerViewController:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return greens.count * blues.count * reds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = colorFor(indexPath: indexPath )
        
        return cell
    }
    
    func colorFor(indexPath: IndexPath) -> UIColor {
        /*
         Color table
         Строки -
         Голубой = константа
         Зеленый 0 - макс - макс - 0 0 макс ...
         КРасный 1           2        3    до середины
         
         Столбцы Голубой 0 - макс (первая полпвин красного); макс - 0 (вторая полпвина красного)
         */
        
        let row = indexPath.row / hItemsCount
        let column = indexPath.row % hItemsCount
        
        var iBlue: Int = 0
        var iRed: Int = 0
        var iGreen: Int = 0
        
        iRed = column / greens.count
        iGreen = column % greens.count
        if iRed % 2 == 0 {
            iGreen = greens.count - iGreen - 1
        }
        
        if row < blues.count {
            iBlue = row
        } else {
            iBlue = blues.count * 2 - row - 1
            iRed = iRed + reds.count / 2
        }
        
        let color = UIColor(red: CGFloat( reds[iRed]) / 256, green: CGFloat(greens[iGreen]) / 256, blue: CGFloat(blues[iBlue]) / 256, alpha: CGFloat(1))
        return color
    }
    
}

extension ColorPickerViewController: UINavigationBarDelegate {
    
}


