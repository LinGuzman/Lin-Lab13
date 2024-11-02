//
//  ElegirUsuarioViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 30/10/24.
//

import UIKit
import Firebase
import FirebaseDatabase



class ElegirUsuarioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  
    
    

    @IBOutlet weak var listaUsuarios: UITableView!
    var usuarios:[Usuario] = []
    var imagenURL: String = ""
    var descrip: String = ""
    var imagenID = ""
    var audioURL: String = ""
    var titulo: String = ""
    var audioID = ""
    
    enum TipoMensaje {
            case mensaje
            case audio
        }
    var tipoMensaje: TipoMensaje?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        
        Database.database().reference()
            .child("usuarios")
            .observe(DataEventType.childAdded) { snapshot in
                print(snapshot)
            
            let usuario = Usuario()
                usuario.email = (snapshot.value as! NSDictionary)["email"] as! String
                usuario.uid = snapshot.key
                self.usuarios.append(usuario)
                self.listaUsuarios.reloadData()

            }}
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell

    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let usuario = usuarios[indexPath.row]
////        let snap: [String: Any] = [
////            "from": Auth.auth().currentUser?.email ?? "",
////            "descripcion": descrip,
////            "imagenURL": imagenURL,
////            "imagenID": imagenID
////        ]
//        let usuario = usuarios[indexPath.row]
//                var snap: [String: Any] = [
//                    "from": Auth.auth().currentUser?.email ?? ""
//                ]
//
//                // Agregar datos según el tipo de mensaje
//                switch tipoMensaje {
//                case .mensaje:
//                    snap["descripcion"] = descrip
//                    snap["imagenURL"] = imagenURL
//                    snap["imagenID"] = imagenID
//                case .audio:
//                    snap["descripcion"] = titulo  // Título o descripción del audio
//                    snap["audioURL"] = audioURL    // URL del audio
//                    snap["audioID"] = audioID      // ID del audio
//                case .none:
//                    break // Manejar caso en el que no se haya establecido el tipo
//                }
//
//        Database.database().reference()
//            .child("usuarios")
//            .child(usuario.uid)
//            .child("snaps")
//            .childByAutoId()
//            .setValue(snap)
//
//        navigationController?.popViewController(animated: true)
//
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]

        // Aquí creamos el diccionario snap con los datos del audio
        let snap: [String: Any] = [
            "from": Auth.auth().currentUser?.email ?? "",
            "descripcion": titulo, // Usamos el título del audio
            "audioURL": audioURL, // Usamos la URL del audio
            "audioID": audioID // Usamos el ID del audio
        ]

        // Guardamos el diccionario en Firebase
        Database.database().reference()
            .child("usuarios")
            .child(usuario.uid)
            .child("snaps")
            .childByAutoId()
            .setValue(snap)

        navigationController?.popViewController(animated: true)
    }



}
