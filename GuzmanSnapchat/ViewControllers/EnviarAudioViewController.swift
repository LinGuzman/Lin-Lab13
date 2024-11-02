//
//  EnviarAudioViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 2/11/24.
//

import UIKit
import AVFoundation
import FirebaseStorage
import Firebase


class EnviarAudioViewController: UIViewController {
    
    
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var tituloTextField: UITextField!
    
    @IBOutlet weak var enviarButton: UIButton!
    
    
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var audioID = NSUUID().uuidString

   
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        enviarButton.isEnabled = false

    }
     
    func configurarGrabacion() {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.overrideOutputAudioPort(.speaker)
                try session.setActive(true)
                
                let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let pathComponents = [basePath, "\(audioID).m4a"]
                audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
                
                var settings: [String: AnyObject] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject
                settings[AVSampleRateKey] = 44100.0 as AnyObject
                settings[AVNumberOfChannelsKey] = 2 as AnyObject
                
                grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
                grabarAudio!.prepareToRecord()
            } catch {
                print("Error al configurar la grabación: \(error)")
            }
        }
    
    
            
    
    @IBAction func grabarTapped(_ sender: Any) {
        guard let grabarAudio = grabarAudio else {
                    print("grabarAudio es nil")
                    return
                }
                
                if grabarAudio.isRecording {
                    grabarAudio.stop()
                    grabarButton.setTitle("Grabar", for: .normal)
                    reproducirButton.isEnabled = true
                    enviarButton.isEnabled = true
                } else {
                    grabarAudio.record()
                    grabarButton.setTitle("Detener", for: .normal)
                    reproducirButton.isEnabled = false
                }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        guard let audioURL = audioURL else {
                    print("audioURL es nil")
                    return
                }
                
                do {
                    try reproducirAudio = AVAudioPlayer(contentsOf: audioURL)
                    reproducirAudio!.play()
                } catch {
                    print("Error al reproducir el audio: \(error)")
                }
    }
    
    
    @IBAction func enviarTapped(_ sender: Any) {
        enviarButton.isEnabled = false
                guard let audioURL = audioURL, let audioData = try? Data(contentsOf: audioURL) else {
                    mostrarAlerta(titulo: "Error", mensaje: "El archivo de audio no existe o no se puede acceder.", accion: "OK")
                    enviarButton.isEnabled = true
                    return
                }
                
                let audiosFolder = Storage.storage().reference().child("audios")
                let cargarAudio = audiosFolder.child("\(audioID).m4a")
                
                cargarAudio.putData(audioData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                        self.enviarButton.isEnabled = true
                        print("Ocurrió un error al subir el audio: \(error.localizedDescription)")
                        return
                    } else {
                        cargarAudio.downloadURL { (url, error) in
                            if let error = error {
                                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener la URL del audio.", accion: "Cancelar")
                                self.enviarButton.isEnabled = true
                                print("Ocurrió un error al obtener la URL del audio: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let enlaceURL = url else {
                                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la URL de descarga.", accion: "Aceptar")
                                self.enviarButton.isEnabled = true
                                return
                            }
                            
                            // Si la URL es válida, realiza la transición
                            print("URL del audio obtenida: \(enlaceURL.absoluteString)")
                            self.performSegue(withIdentifier: "seleccionarContactoSegue1", sender: enlaceURL.absoluteString)
                        }
                    }
                }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "seleccionarContactoSegue1" {
               let siguienteVC = segue.destination as! ElegirUsuarioViewController

               // Verifica si sender es del tipo String
               if let audioURL = sender as? String {
                   siguienteVC.audioURL = audioURL
               } else {
                   print("Error: sender no es un String o es nil")
                   mostrarAlerta(titulo: "Error", mensaje: "No se pudo enviar la URL de audio.", accion: "OK")
               }

               siguienteVC.titulo = tituloTextField.text ?? ""
               siguienteVC.audioID = audioID
           }
       }

       func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
           if presentedViewController == nil {
               let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
               let btnCancelarOK = UIAlertAction(title: accion, style: .default, handler: nil)
               alerta.addAction(btnCancelarOK)
               present(alerta, animated: true, completion: nil)
           }
       }
}
