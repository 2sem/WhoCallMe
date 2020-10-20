//
//  LSSettingsViewController.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2020/09/12.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit
import RxSwift

class LSSettingsViewController: UITableViewController {
    
    var disposeBag = DisposeBag();

    @IBOutlet weak var contactPhotoSwitch: UISwitch!
    @IBOutlet weak var contactNicknameSwitch: UISwitch! //create if original nickname is empty
    @IBOutlet weak var contactOrganizationSwitch: UISwitch!
    @IBOutlet weak var contactDepartmentSwitch: UISwitch!
    @IBOutlet weak var contactJobTitleSwitch: UISwitch!
    @IBOutlet weak var contactChosengSwitch: UISwitch!
    
    @IBOutlet weak var photoFullscreenSwitch: UISwitch!
    @IBOutlet weak var photoOrganizationSwitch: UISwitch!
    @IBOutlet weak var photoDepartmentSwitch: UISwitch!
    @IBOutlet weak var photoJobTitleSwitch: UISwitch!
    
    @IBOutlet weak var vertionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.isHidden = false;
        self.navigationController?.navigationBar.tintColor = .black;
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView?.hideExtraRows = true;
        
        self.updateInfo();
        self.setupBinding();
    }
    
    func setupBinding(){
        self.contactNicknameSwitch.rx.isOn.bind { (value) in
            LSDefaults.needGenerateNickname = value;
        }.disposed(by: self.disposeBag);
        
        self.contactOrganizationSwitch.rx.isOn.bind { (value) in
            LSDefaults.needContainsOrg = value;
        }.disposed(by: self.disposeBag);
        
        self.contactDepartmentSwitch.rx.isOn.bind { (value) in
            LSDefaults.needContainsDept = value;
        }.disposed(by: self.disposeBag);
        
        self.contactJobTitleSwitch.rx.isOn.bind { (value) in
            LSDefaults.needContainsJob = value;
        }.disposed(by: self.disposeBag);
        
        self.contactChosengSwitch.rx.isOn.bind { (value) in
            LSDefaults.needMakeChoseong = value;
        }.disposed(by: self.disposeBag);
        
        self.contactPhotoSwitch.rx.isOn.bind { [weak self](value) in
            LSDefaults.needMakeIncomingPhoto = value;
            self?.updateIncomingCall();
        }.disposed(by: self.disposeBag);
        
        self.photoFullscreenSwitch.rx.isOn.bind { (value) in
            guard LSDefaults.needMakeIncomingPhoto else{
                return;
            }
            
            LSDefaults.needFullscreenPhoto = value;
        }.disposed(by: self.disposeBag);
        
        self.photoOrganizationSwitch.rx.isOn.bind { (value) in
            guard LSDefaults.needMakeIncomingPhoto else{
                return;
            }
            
            LSDefaults.needPhotoContainsOrg = value;
        }.disposed(by: self.disposeBag);
        
        self.photoDepartmentSwitch.rx.isOn.bind { (value) in
            guard LSDefaults.needMakeIncomingPhoto else{
                return;
            }
            
            LSDefaults.needPhotoContainsDept = value;
        }.disposed(by: self.disposeBag);
        
        self.photoJobTitleSwitch.rx.isOn.bind { (value) in
            guard LSDefaults.needMakeIncomingPhoto else{
                return;
            }
            
            LSDefaults.needPhotoContainsJob = value;
        }.disposed(by: self.disposeBag);
    }
    
    func updateInfo(){
        self.contactNicknameSwitch.isOn = LSDefaults.needGenerateNickname;
        self.contactOrganizationSwitch.isOn = LSDefaults.needContainsOrg;
        self.contactDepartmentSwitch.isOn = LSDefaults.needContainsDept;
        self.contactJobTitleSwitch.isOn = LSDefaults.needContainsJob;
        self.contactChosengSwitch.isOn = LSDefaults.needMakeChoseong;
        self.contactPhotoSwitch.isOn = LSDefaults.needMakeIncomingPhoto;

        self.updateIncomingCall();
        
        self.vertionLabel?.text = UIApplication.shared.version;
    }
    
    func updateIncomingCall(){
        self.photoFullscreenSwitch.isEnabled = self.contactPhotoSwitch.isOn;
        self.photoFullscreenSwitch.isOn = self.contactPhotoSwitch.isOn && LSDefaults.needFullscreenPhoto;
        
        self.photoOrganizationSwitch.isEnabled = self.contactPhotoSwitch.isOn;
        self.photoOrganizationSwitch.isOn = self.contactPhotoSwitch.isOn &&  LSDefaults.needPhotoContainsOrg;
        
        self.photoDepartmentSwitch.isEnabled = self.contactPhotoSwitch.isOn;
        self.photoDepartmentSwitch.isOn = self.contactPhotoSwitch.isOn &&  LSDefaults.needPhotoContainsDept;
        
        self.photoJobTitleSwitch.isEnabled = self.contactPhotoSwitch.isOn;
        self.photoJobTitleSwitch.isOn = self.contactPhotoSwitch.isOn &&  LSDefaults.needPhotoContainsJob;
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
