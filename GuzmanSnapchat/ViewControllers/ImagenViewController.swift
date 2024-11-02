//
//  ImagenViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 23/10/24.
//

import UIKit
import FirebaseStorage
import CoreData

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageview.image = image
        imageview.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true,completion: nil)
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)

    }
    
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData = imageview.image?.jpegData(compressionQuality: 0.5)

        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")

        cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrió un error al subir la imagen: \(error.localizedDescription)")
                return
            } else {
                cargarImagen.downloadURL { (url, error) in
                    guard let enlaceURL = url else {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen.", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrió un error al obtener información de la imagen: \(error?.localizedDescription ?? "Error desconocido")")
                        return
                    }
                    self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: url?.absoluteString)
                }
            }
        }
        /*
         let alertaCarga = UIAlertController(title: "Cargando Imagen...", message: "0%", preferredStyle: .alert)
         let progresoCarga = UIProgressView(progressViewStyle: .default)

         cargarImagen.observe(.progress) { snapshot in
             let porcentaje = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
             print(porcentaje)
             progresoCarga.setProgress(Float(porcentaje), animated: true)
             progresoCarga.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
             alertaCarga.message = String(round(porcentaje * 100.0)) + "%"
             
             if porcentaje >= 1.0 {
                 alertaCarga.dismiss(animated: true, completion: nil)
             }
         }

         let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
         alertaCarga.addAction(btnOK)
         alertaCarga.view.addSubview(progresoCarga)
         present(alertaCarga, animated: true, completion: nil)

         */

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
    }

    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCancelarOK = UIAlertAction(title: accion, style: .default, handler: nil)
        
        alerta.addAction(btnCancelarOK)
        present(alerta, animated: true, completion: nil)
    }
    
    



}
