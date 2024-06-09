//
//  ContactTemplateViewController.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 11..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import Contacts
import FirebaseAnalytics

/**
    view controller to create and preview call receive image
 */
class ContactTemplateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    class Cell_Ids{
        static let ContactImageCell = "ContactImageCell";
        static let ContactOrgCell = "ContactOrgCell";
        static let ContactDeptCell = "ContactDeptCell";
        static let ContactJobCell = "ContactJobCell";
    }
    
    enum InfoType : Int{
        case photo = 0
        case organization = 1
        case department = 2
        case jobTitle = 3
        
        static let Count = jobTitle.rawValue + 1;
    }
    
    fileprivate var cells : [InfoType] = [InfoType.photo, InfoType.organization, InfoType.department, InfoType.jobTitle];

    var contact : CNContact?;
    
    var originalImage : UIImage?;
    
    /// original photo of the contact
    fileprivate var photo : UIImage?{
        get{
            var value : UIImage?;
            
            if self.originalImage != nil{
                value = self.originalImage;
            }
            else if self.contact?.imageData != nil{
                value = UIImage(data: self.contact!.imageData!);
            }
            
            return value;
        }
    }
    
    var isPreviewMode : Bool = false{
        didSet{
            self.lb_name?.isHidden = !self.isPreviewMode;
            self.lb_status?.isHidden = !self.isPreviewMode;
            self.darkCoverView?.isHidden = !self.isPreviewMode;
            self.callCommandView?.isHidden = !self.isPreviewMode;
        }
    }
    
    var useThumbNail : Bool = false{
        didSet{
            self.img_background?.image = self.useThumbNail ? nil : self.photo;
            
            self.showInfo(.photo, visible: self.useThumbNail);
        }
    }
    
    @IBOutlet weak var img_background: UIImageView!
    @IBOutlet weak var darkCoverView: UIView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_status: UILabel!
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var callCommandView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Makes navigationbar transparent
        self.navigationController?.navigationBar.shadowImage = UIImage();
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);

        self.isPreviewMode = Bool(self.isPreviewMode);
        self.refreshName();
        self.useThumbNail = Bool(self.useThumbNail);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.setScreenName(for: self);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent;
    }
    
    /**
        Toggle information to draw on the ringing image
    */
    func showInfo(_ type : InfoType, visible: Bool ){
        let idx = self.cells.firstIndex(of: type);
        
        if visible {
            if idx == nil{
                self.cells.append(type);
                self.cells = self.cells.sorted(by: { (left, right) -> Bool in
                    return left.rawValue < right.rawValue;
                });
            }
        }else{
            if idx != nil{
                self.cells.remove(at: idx!);
            }
        }
        
        self.infoTable?.reloadData();
    }
    
    func showAllInfos(){
        self.cells.removeAll();
        for i in 0..<InfoType.Count{
            let type = InfoType(rawValue: i);
            self.cells.append(type!);
        }

        self.infoTable?.reloadData();
    }
    
    func removeUnavailableInfos(){
        let types = self.cells;
        for type in types {
            let idx = self.cells.firstIndex(of: type);
            switch(type){
                case .photo:
                    if self.contact?.imageData == nil{
                        self.cells.remove(at: idx!);
                    }
                    break;
                case .organization:
                    if self.contact?.organizationName.isEmpty == true || !LSDefaults.needPhotoContainsOrg{
                        self.cells.remove(at: idx!);
                    }
                    break;
                case .department:
                    if self.contact?.departmentName.isEmpty == true || !LSDefaults.needPhotoContainsDept{
                        self.cells.remove(at: idx!);
                    }
                    break;
                case .jobTitle:
                    if self.contact?.jobTitle.isEmpty == true || !LSDefaults.needPhotoContainsJob{
                        self.cells.remove(at: idx!);
                    }
                    break;
            }
        }
    }
    
    fileprivate func refreshName(){
        if self.isPreviewMode {
            self.lb_name?.text = self.contact?.fullName;
        }
    }

    /// MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var value = UITableView.automaticDimension;
        
        let index = self.cells[indexPath.row].rawValue;
        switch(InfoType(rawValue: index)!){
            case .photo:
                value = 150;
                break;
            default:
                break;
        }
        
        return value;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var value : UITableViewCell?;
        
        let index = self.cells[indexPath.row].rawValue;
        switch(InfoType(rawValue: index)!){
        case .photo:
            let cell = self.infoTable.dequeueReusableCell(withIdentifier: Cell_Ids.ContactImageCell) as? ContactImageCell;
            value = cell;
            if self.originalImage != nil{
                cell?.contactImage.image = self.originalImage;
            }
            else if self.contact?.imageData != nil{
                cell?.contactImage.image = UIImage(data: self.contact!.imageData!);
            }
            //cell?.optionValue = false;
            break;
        case .organization:
            let cell = self.infoTable.dequeueReusableCell(withIdentifier: Cell_Ids.ContactOrgCell) as? ContactOrgCell;
            cell?.valueLabel.text = self.contact?.organizationName;
            value = cell;
            break;
        case .department:
            let cell = self.infoTable.dequeueReusableCell(withIdentifier: Cell_Ids.ContactDeptCell) as? ContactDeptCell;
            cell?.valueLabel.text = self.contact?.departmentName;
            
            value = cell;
            break;
        case .jobTitle:
            let cell = self.infoTable.dequeueReusableCell(withIdentifier: Cell_Ids.ContactJobCell) as? ContactJobCell;
            cell?.valueLabel.text = self.contact?.jobTitle;

            value = cell;
            break;
        }
        
        if value == nil{
            value = UITableViewCell();
        }
        
        return value!;
    }
    
    func refreshContact(){
        let cnt = self.infoTable.numberOfRows(inSection: 0);
        for i in 0...cnt where cnt >= 0{
            self.refreshContactInfo(IndexPath(row: i, section: 0));
        }
    }
    func refreshContactInfo(_ indexPath : IndexPath){
        
        let index = self.cells[indexPath.row].rawValue;
        
        switch(InfoType(rawValue: index)!){
            case .photo:
                let photoCell = self.infoTable.cellForRow(at: indexPath) as? ContactImageCell;

                if self.originalImage != nil{
                    photoCell?.contactImage.image = self.originalImage;
                }
                else if self.contact?.imageData != nil{
                    photoCell?.contactImage.image = UIImage(data: self.contact!.imageData!);
                }
                break;
            case .organization:
                let orgCell = self.infoTable.cellForRow(at: indexPath) as? ContactOrgCell;
                orgCell?.valueLabel.text = self.contact?.organizationName;
                break;
            case .department:
                let deptCell = self.infoTable.cellForRow(at: indexPath) as? ContactDeptCell;
                deptCell?.valueLabel.text = self.contact?.departmentName;
                break;
            case .jobTitle:
                let deptCell = self.infoTable.cellForRow(at: indexPath) as? ContactJobCell;
                deptCell?.valueLabel.text = self.contact?.jobTitle;
                break;
        }
    }
    
    func refresh(){
        self.removeUnavailableInfos();
        self.infoTable?.reloadData();
        self.refreshName();
        self.useThumbNail = Bool(self.useThumbNail);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
