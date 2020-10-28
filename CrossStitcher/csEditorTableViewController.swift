//
//  csEditorTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 28/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit

class csEditorTableViewController: UITableViewController {
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
