//
//  ColorChooserViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 02.03.2024.
//

import UIKit

class ColorChooserViewController: UIViewController {
    var presenter: ColorPickerPresenterProtocol!
    var currentColor: UIColor? {
        didSet {
            self.currentColorView.backgroundColor = currentColor
//            if let row = selectedRowIndex {
//                let indexPathForColor = IndexPath(row: row, section: 0)
//                self.colorTableView.selectRow(at: indexPathForColor, animated: true, scrollPosition: UITableView.ScrollPosition.none)
//            }
        }
    }
    
    private var selectedRowIndex: Int? {
        if let currentColor = currentColor {
            return colors.firstIndex(of: currentColor)
        }
        return nil
    }

    /*
    private let reds = [0xEE, 0xCC, 0xAA, 0x88, 0x66, 0x44, 0x22, 0x00, 0xFF, 0xDD, 0xBB, 0x99, 0x77, 0x55, 0x33, 0x11]
    private let greens = [0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]
    private let blues = [0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]
     */
//    private let reds = [0xFF, 0xCC, 0x99, 0x66, 0x33, 0x00]
//    private let greens = [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]//[0x00, 0x22, 0x44, 0x66, 0x88, 0xAA, 0xCC, 0xFF]
//    private let blues = [0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]//[0x00, 0x22, 0x44, 0x66, 0x88, 0xAA, 0xCC, 0xFF]
    
    private let sequence = [0x00, 0x22, 0x44, 0x66, 0x88, 0xAA, 0xCC, 0xFF]//[0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF]
    //private let reverseArr = [0xFF, 0xCC, 0x99, 0x66, 0x33, 0x00]
    
    private var colors = [UIColor]()

    @IBOutlet weak var sampleImageView: UIImageView!
    @IBOutlet weak var alfaSlider: UISlider!
    @IBOutlet weak var colorTableView: UITableView!
    @IBOutlet weak var currentColorView: UIView!
    
    @IBAction func alfaChanged(_ sender: UISlider) {
        self.colorTableView.alpha = CGFloat(sender.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
        
        self.colorTableView.register(UITableViewCell.self, forCellReuseIdentifier: "colorCell")
//        for blue in blues {
//            for green in greens {
//                for red in reds {
//                    let color = UIColor(red: CGFloat(red) / 256, green: CGFloat(green) / 256, blue: CGFloat(blue) / 256, alpha: 1.0)
//                    colors.append(color)
//                }
//            }
//        }
        var redIndex = sequence.count - 1
        var greenIndex = 0
        var blueIndex = 0
        
        // red = max, increase green
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            greenIndex += 1
        }
        greenIndex -= 1
 
        // red & green = max
        // decrease red
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            redIndex -= 1
        }
        redIndex = 0

        // green max, increase blue
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            blueIndex += 1
        }
        blueIndex -= 1
        
        // green & blue max, decrease green
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            greenIndex -= 1
        }
        greenIndex = 0
        
        // blue max, increase red
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            redIndex += 1
        }
        redIndex -= 1

        // blue & red max, decrease blue
        for _ in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[redIndex]) / 256, green: CGFloat(sequence[greenIndex]) / 256, blue: CGFloat(sequence[blueIndex]) / 256, alpha: 1.0)
            colors.append(color)
            blueIndex -= 1
        }
        blueIndex = 0

        // gray scale
        for index in 0..<sequence.count {
            let color = UIColor(red: CGFloat(sequence[index]) / 256, green: CGFloat(sequence[index]) / 256, blue: CGFloat(sequence[index]) / 256, alpha: 1.0)
            colors.append(color)
        }

        let okButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(saveButtonPressed))
        self.navigationItem.rightBarButtonItem  = okButton
    }

    @objc func saveButtonPressed()  {
        presenter.doneAction(currentColor ?? UIColor.white, CGFloat( self.alfaSlider.value))
        self.navigationController?.popViewController(animated: true)
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

extension ColorChooserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = colorTableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath) 
        
        ConfigCell(cell: cell, at: indexPath)
        
        return cell
    }
    
    func ConfigCell(cell: UITableViewCell, at indexPath: IndexPath)  {
        let colorForCell = colors[ indexPath.row ]
        
        cell.backgroundColor = colorForCell
        var content = cell.defaultContentConfiguration()
        if indexPath.row == self.selectedRowIndex {
            //content.text = "->"
            content.image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            content.image = nil
        }
        cell.tintColor = .black
        cell.contentConfiguration = content

    }
    
}

extension ColorChooserViewController: ColorPickerViewProtocol {
    func setSampleImage(with image: UIImage?) {
        self.sampleImageView.image = image
    }
    
    func setCurrentColor(with color: UIColor) {
        self.currentColor = color
    }
    
    func setAlfa(with alfa: CGFloat) {
        self.colorTableView.alpha = alfa
        self.alfaSlider.value = Float(alfa)
    }
    
    
}

extension ColorChooserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellsToRedraw = [indexPath]
        if let selectedRowIndex = selectedRowIndex {
            let oldIndexPath = IndexPath(row: selectedRowIndex, section: 0)
            cellsToRedraw.append(oldIndexPath)
        }
        
        self.currentColor = colors[ indexPath.row ]
        tableView.deselectRow(at: indexPath, animated: true)
        
        for indexPath in cellsToRedraw {
            if let cell = tableView.cellForRow(at: indexPath) {
                ConfigCell(cell: cell, at: indexPath)
                //print("Redraw cell at \(indexPath.row)")
            }
        }
    }
}
