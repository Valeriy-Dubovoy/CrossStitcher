//
//  StitchEditorTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 27.10.2022.
//

import UIKit

class StitchEditorTableViewController: UITableViewController, SchemaViewControllerProtocol, UINavigationControllerDelegate {
    var presenter: SchemaViewControllerPresenterProtocol!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var columnsTextField: UITextField!
    @IBOutlet weak var startRowTextField: UITextField!
    @IBOutlet weak var startColumnTextField: UITextField!
    
    @IBOutlet weak var schemaImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var color1Preview: UIView!
    @IBOutlet weak var color2Preview: UIView!
    
    var color1TapRecognizer: UITapGestureRecognizer?
    var color2TapRecognizer: UITapGestureRecognizer?

    @IBAction func intEditChanged(_ sender: UITextField) {
        if let intValue = Int(sender.text ?? "0") {
            sender.text = String ( intValue )
        } else {
            // remove last simbol
            if let text = sender.text, text.count > 0 {
                sender.text?.removeLast()
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField?.text == nil || nameTextField!.text == "" {
            UniversalSystem.showAlertMessage("EmptyName", withTitle: "Error", inView: self)
            return
        }
        
        presenter.name = nameTextField.text ?? ""
        presenter.rows = Int16( rowsTextField?.text ?? "1") ?? 1
        presenter.startRow = Int16( startRowTextField?.text ?? "1") ?? 1
        presenter.columns = Int16( columnsTextField?.text ?? "1") ?? 1
        presenter.startColumn = Int16( startColumnTextField?.text ?? "1") ?? 1
        presenter.markerColor1 = color1Preview.backgroundColor ?? Constants.marker1Color()
        presenter.markerColor2 = color2Preview.backgroundColor ?? Constants.marker2Color()
        presenter.alfaMarker1 = color1Preview.alpha
        presenter.alfaMarker2 = color2Preview.alpha
        presenter.schemaImage = schemaImageView.image
        presenter.previewImage = previewImageView.image
  
        presenter.saveProperties()

        do {
            try (UIApplication.shared.delegate as? AppDelegate)?.saveContext(inBackground: false)
            //navigationController?.dismiss(animated: true, completion: {})
            // close window
            cancelButtonPressed(sender)
        } catch {
            UniversalSystem.showAlertMessage("Saving error", withTitle: "Error", inView: self)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let vc = presentingViewController {
            vc.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        //navigationController?.dismiss(animated: true, completion: {})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        color1TapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectColor(_:)))
        color1Preview.addGestureRecognizer(color1TapRecognizer!)
        color2TapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectColor(_:)))
        color2Preview.addGestureRecognizer(color2TapRecognizer!)

        updateUI()
    }

    func updateUI() {
        nameTextField.text = presenter.name
        rowsTextField.text = String(presenter.rows)
        startRowTextField.text = String(presenter.startRow)
        columnsTextField.text = String(presenter.columns)
        startColumnTextField.text = String(presenter.startColumn)
        schemaImageView.image = presenter.schemaImage
        previewImageView.image = presenter.previewImage
        
        color1Preview.backgroundColor = presenter.markerColor1
        color2Preview.backgroundColor = presenter.markerColor2
        color1Preview.alpha = presenter.alfaMarker1
        color2Preview.alpha = presenter.alfaMarker2
        
    }
  
    @objc func selectColor(_ sender: UITapGestureRecognizer) {
        //var colorNumber: Int?
        var viewForEdit: UIView?
        var choosenColor = UIColor()
        //var alfa: CGFloat = 0.5
        if sender == color1TapRecognizer {
            //colorNumber = 1
            choosenColor = color1Preview.backgroundColor ?? Constants.marker1Color()
            viewForEdit = color1Preview
        } else if sender == color2TapRecognizer {
            //colorNumber = 2
            choosenColor = color2Preview.backgroundColor ?? Constants.marker2Color()
            viewForEdit = color2Preview
       }
        guard viewForEdit != nil else {return }

        let colorPickerView = ViewsAssembler.createColorPickerView(color: choosenColor, alfa: viewForEdit?.alpha ?? 0.5, sampleImage: schemaImageView.image)
            {color,alfa in
                //print("Choosen color \(color) with opacity \(alfa)")
                viewForEdit?.backgroundColor = color
                viewForEdit?.alpha = alfa
            }

        self.navigationController?.pushViewController(colorPickerView, animated: true)

    }
    
    // MARK: Picking up an Image
    private var imageViewWaitingImage: UIImageView?
    
    // MARK: SchemaViewControllerProtocol
    func updateUndoButtonStatus() {
        // nothing to do
    }

}

// MARK: Picking up an Image

extension StitchEditorTableViewController : UIImagePickerControllerDelegate {
    
    func chooseImageForImageView( iview: UIImageView?) {
        let alertTitle = NSLocalizedString("Image source", comment: "")
        let alertMessage = NSLocalizedString("", comment: "")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = iview
        alert.popoverPresentationController?.sourceRect = iview?.frame ?? CGRect()
        
        imageViewWaitingImage = iview
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler:
                                { _ in
                                    self.startGettingImageFrom(sourceType: .camera)
                                }
                             )
            )
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Photo album", comment: ""), style: .default, handler:
                                { _ in
                                    self.startGettingImageFrom(sourceType: .savedPhotosAlbum)
                                }
                             )
            )
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Photo library", comment: ""), style: .default, handler:
                                { _ in
                                    self.startGettingImageFrom(sourceType: .photoLibrary)
                                }
                             )
            )
        }
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: nil)
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func startGettingImageFrom(sourceType: UIImagePickerController.SourceType) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = sourceType
        //imgPicker.mediaTypes = [kUTTypeImage]
        
        imgPicker.delegate = self
        self.present(imgPicker, animated: true) {
            print("image choosen")        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img = info[.editedImage] as? UIImage {
            imageViewWaitingImage?.image = img
        } else if let img = info[.originalImage] as? UIImage {
            imageViewWaitingImage?.image = img
        } else {
            imageViewWaitingImage?.image = nil
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension StitchEditorTableViewController {
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // schema
            chooseImageForImageView(iview: schemaImageView)
        case 3:
            //preview
            chooseImageForImageView(iview: previewImageView)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // schema
            chooseImageForImageView(iview: schemaImageView)
        case 3:
            //preview
            chooseImageForImageView(iview: previewImageView)
        default:
            break
        }
    }

}
