//
//  VerSnapViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 31/10/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVFoundation

class VerSnapViewController: UIViewController {
    
    
    @IBOutlet weak var lblMensaje: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    var snap = Snap()
        var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configura el mensaje
            lblMensaje.text = "Título: " + snap.descrip
            
            // Deshabilita el botón de reproducción hasta que el audio esté listo
            playButton.isEnabled = false
            
            // Descarga el audio desde Firebase Storage y configúralo para su reproducción
            let audioURL = URL(string: snap.audioURL)
            descargarAudioDesde(url: audioURL)
        }
        
        func descargarAudioDesde(url: URL?) {
            guard let audioURL = url else {
                print("URL de audio inválida.")
                return
            }
            
            // Descarga el archivo de audio
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: audioURL) { (tempLocalUrl, response, error) in
                if let error = error {
                    print("Error al descargar el audio: \(error)")
                    return
                }
                
                guard let tempLocalUrl = tempLocalUrl else {
                    print("URL temporal no disponible.")
                    return
                }
                
                do {
                    // Inicializa el reproductor de audio con el archivo descargado
                    self.audioPlayer = try AVAudioPlayer(contentsOf: tempLocalUrl)
                    DispatchQueue.main.async {
                        self.playButton.isEnabled = true // Habilita el botón de reproducción
                    }
                } catch {
                    print("Error al reproducir el audio: \(error)")
                }
            }
            
            downloadTask.resume()
        }

    @IBAction func playTapped(_ sender: Any) {
        
        // Reproduce o pausa el audio
                if let player = audioPlayer {
                    if player.isPlaying {
                        player.pause()
                        playButton.setTitle("Reproducir", for: .normal)
                    } else {
                        player.play()
                        playButton.setTitle("Pausar", for: .normal)
                    }
                }
        
        

        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Elimina el registro del audio en la base de datos y el archivo en Firebase Storage
            Database.database().reference()
                .child("usuarios")
                .child(Auth.auth().currentUser?.uid ?? "")
                .child("snaps")
                .child(snap.id)
                .removeValue()
            
            Storage.storage().reference()
                .child("audios")
                .child("\(snap.audioID).m4a")
                .delete { (error) in
                    if error == nil {
                        print("Se eliminó el audio correctamente")
                    } else {
                        print("Error al eliminar el audio: \(error?.localizedDescription ?? "Error desconocido")")
                    }
                }
        }
    
    
    
}
