//
//  ViewController.swift
//  GuzmanSnapchat
//
//  Created by Lin Abigail Guzman Gutierrez on 16/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            print("Intentando Iniciar Sesion")
            if error != nil {
                print("Se presento el siguiente error: \(error!)")
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password:
                                        self.passwordTextField.text!, completion: { (user, error) in
                    print("Intentando crear un usuario")
                    if error != nil{
                        print("Se presento el siguiente error al crear el usuario:\(error)")
                    }else{
                        print("El usurio fue creado exitosamente")
                        
                        Database.database().reference()
                            .child("usuarios")
                            .child(user!.user.uid)
                            .child("email")
                            .setValue(user!.user.email)

                        
                        
                        let alerta = UIAlertController(
                            title: "Creación de Usuario",
                            message: "Usuario: \(self.emailTextField.text!) se creó correctamente.",
                            preferredStyle: .alert
                        )

                        let btnOK = UIAlertAction(title: "Aceptar", style: .default) { _ in
                            self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                        }

                        alerta.addAction(btnOK)
                        self.present(alerta, animated: true, completion: nil)

                        
                        self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                    }
                })
            } else {
                print("Inicio de sesion exitoso")
                
                
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    
    


}

