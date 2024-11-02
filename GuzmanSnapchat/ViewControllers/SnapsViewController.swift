//
//  SnapsViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 23/10/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class SnapsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    
    
    @IBOutlet weak var cerrar: UIBarButtonItem!
    
    
    @IBOutlet weak var tablaSnaps: UITableView!
     var snaps:[Snap] = []
    
   
    override func viewDidLoad() {
            super.viewDidLoad()
            
            tablaSnaps.delegate = self
            tablaSnaps.dataSource = self
            
            // Observar los audios añadidos
            Database.database().reference()
                .child("usuarios")
                .child(Auth.auth().currentUser?.uid ?? "")
                .child("snaps")
                .observe(DataEventType.childAdded, with: { (snapshot) in

                    let snap = Snap()
                    
                    if let snapData = snapshot.value as? NSDictionary {
                        snap.id = snapshot.key
                        snap.from = snapData["from"] as? String ?? "Desconocido"
                        snap.descrip = snapData["descripcion"] as? String ?? "Sin descripción"
                        
                        // Solo captura audios
                        if let audioURL = snapData["audioURL"] as? String {
                            snap.audioURL = audioURL
                            snap.audioID = snapData["audioID"] as? String ?? ""
                        } else {
                            print("Error: audioURL no existe en snapData.")
                            return // Salir si no hay audio
                        }
                        
                        self.snaps.append(snap)
                        self.tablaSnaps.reloadData()
                    } else {
                        print("Error: snapshot.value no se puede convertir a NSDictionary.")
                    }
                })

            // Observar los audios eliminados
            Database.database().reference()
                .child("usuarios")
                .child(Auth.auth().currentUser?.uid ?? "")
                .child("snaps")
                .observe(DataEventType.childRemoved, with: { (snapshot) in
                    
                    var iterator = 0
                    for snap in self.snaps {
                        if snap.id == snapshot.key {
                            self.snaps.remove(at: iterator)
                            break
                        }
                        iterator += 1
                    }
                    self.tablaSnaps.reloadData()
                })
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return snaps.isEmpty ? 1 : snaps.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()
            if snaps.isEmpty {
                cell.textLabel?.text = "No Tienes Snaps 😰"
            } else {
                let snap = snaps[indexPath.row]
                cell.textLabel?.text = "🔊 Audio de \(snap.from)"
            }
            return cell
        }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "versnapsegue", sender: snap)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "versnapsegue" {
            let siguienteVC = segue.destination as! VerSnapViewController
            siguienteVC.snap = sender as! Snap
        }
    }
        
    
    
    
    @IBAction func cerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    



}
