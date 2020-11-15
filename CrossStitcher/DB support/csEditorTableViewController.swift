//
//  csEditorTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 28/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit

class csEditorTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var edittingItem: CrossStitch? {
        didSet {
            updateUI()
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var columnsTextField: UITextField!
    @IBOutlet weak var schemaImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        doneAction()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelAction()
    }
    
    var imageViewWaitingImage: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

        //self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction)))

        //self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction)))
    }

    private func updateUI() {
        nameTextField?.text = edittingItem?.name
        rowsTextField?.text = String( edittingItem?.gridRows ?? 0 )
        columnsTextField?.text = String( edittingItem?.gridColumns ?? 0 )
        if let imageData = edittingItem?.schemaData {
            schemaImageView?.image = UIImage(data: imageData)
        }
        if let imageData = edittingItem?.imageData {
            previewImageView?.image = UIImage(data: imageData)
        }
    }

    @objc func doneAction() {
        if nameTextField?.text == nil || nameTextField!.text == "" {
            (UIApplication.shared.delegate as? AppDelegate)?.showAlertMessage("EmptyName", withTitle: "Error", inView: self)
            return
        }
        var csObject = edittingItem
        if csObject == nil {
            //insert new object
            csObject = CrossStitch.init(context: AppDelegate.managedObjectContext)
            
        } else {
            // update object
        }
        csObject!.name = nameTextField.text
        csObject!.gridRows = Int16( rowsTextField.text ?? "0" ) ?? 0
        csObject!.gridColumns = Int16( columnsTextField.text ?? "0" ) ?? 0
        
        csObject?.schemaData = schemaImageView?.image?.pngData()
        csObject?.imageData = previewImageView?.image?.pngData()
        
        
        do {
            try (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            navigationController?.dismiss(animated: true, completion: {})
            //navigationController?.popViewController(animated: true)
        } catch {
            (UIApplication.shared.delegate as? AppDelegate)?.showAlertMessage("Saving error", withTitle: "Error", inView: self)
        }
        edittingItem = csObject
    }
    
    @objc func cancelAction() {
        navigationController?.dismiss(animated: true, completion: {})
        //popViewController(animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            //schema
            chooseImageForImageView(iview: schemaImageView)
        case 3:
            //preview
            chooseImageForImageView(iview: previewImageView)
        default:
            break
        }
    }
    // MARK: Picking up an Image
    func chooseImageForImageView( iview: UIImageView?) {
        let alertTitle = NSLocalizedString("Image source", comment: "")
        let alertMessage = NSLocalizedString("", comment: "")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        
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
        
        imgPicker.delegate = self// as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.present(imgPicker, animated: true) {
            print("image choosen")        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img = info[.editedImage] as? UIImage {
            imageViewWaitingImage?.image = img
        } else if let img = info[.originalImage] as? UIImage {
            imageViewWaitingImage?.image = img
        } else {
            imageViewWaitingImage?.image = nil
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
