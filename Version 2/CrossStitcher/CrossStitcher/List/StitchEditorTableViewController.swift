//
//  StitchEditorTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 27.10.2022.
//

import UIKit

class StitchEditorTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var stitchModel = StitchModel() {
        didSet {
            //updateUI() - don't use because it start at every change any property
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var columnstextField: UITextField!
    
    @IBOutlet weak var schemaImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
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
        
        stitchModel.set(name: nameTextField.text ?? "")
        let intRows = Int( rowsTextField?.text ?? "10")
        stitchModel.set(rows: Int16( intRows ?? 10 ) )
        stitchModel.set(columns: Int16(columnstextField?.text ?? "1") ?? 1)

        stitchModel.set(schemaImage: schemaImageView.image)
        stitchModel.set(previewImage: previewImageView.image)

        if stitchModel.stitch == nil {
            stitchModel.newStitch()
        }
        
        do {
            try (UIApplication.shared.delegate as? AppDelegate)?.saveContext(inBackground: false)
            navigationController?.dismiss(animated: true, completion: {})
        } catch {
            UniversalSystem.showAlertMessage("Saving error", withTitle: "Error", inView: self)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: {})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        updateUI()
    }

    func updateUI() {
        nameTextField?.text = stitchModel.getName()
        rowsTextField?.text = String( Int( stitchModel.getRows() ) )
        columnstextField?.text = String( Int( stitchModel.getColumns() ) )
        schemaImageView?.image = stitchModel.getSchemaImage()
        previewImageView?.image = stitchModel.getPreviewImage()
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            // schema
            chooseImageForImageView(iview: schemaImageView)
        case 2:
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
        case 2:
            //preview
            chooseImageForImageView(iview: previewImageView)
        default:
            break
        }
    }
  
    // MARK: Picking up an Image
    private var imageViewWaitingImage: UIImageView?

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

  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
