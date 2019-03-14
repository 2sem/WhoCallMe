//
//  MainViewController.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 10..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import CoreData
import GoogleMobileAds
import LSExtensions
import RxSwift
import RxCocoa
import LSCircleProgressView
import Crashlytics

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactPickerDelegate, GADBannerViewDelegate {
    
    class Cell_Ids{
        static let OptionPhotoCell = "OptionPhotoCell";
    }
    
    @IBOutlet weak var constraint_bottomBanner_Bottom : NSLayoutConstraint!;
    @IBOutlet weak var constraint_bottomBanner_Top: NSLayoutConstraint!
    
    let WhoCallMeSearchTag = "WhoCallMe";
    #if DEBUG
    let enableAds = false;
    #else
    let enableAds = true;
    #endif
    
    enum OptionIndex : Int{
        case thumnail = 0
//        case Organization = 1
//        case Department = 2
//        case JobTitle = 3
        
        static let Count = thumnail.rawValue + 1;
    }
    
    enum GenerateStep : Int{
        case ready = 0
        case backupOriginal = 1
        case findOriginal = 2
        case checkOriginal = 3
        case createImage = 4
        case createIndex = 5
        case removeIndex = 6
        case removeImage = 7
        case saveContact = 8
        case saveData = 9
        
        static let Count = saveData.rawValue + 1;
    }
    static var genStep = GenerateStep.ready;
    
    let contactStore = CNContactStore();
    let msgs = WCMMessageManager();
    let progressedCount = BehaviorSubject<Int>(value: 0);
    func increaseProgressed(){
        let value = try! self.progressedCount.value();
        self.progressedCount.onNext(value + 1);
        print("increase progress => \(value + 1)");
    }
    let totalCount = BehaviorSubject<Int>(value: 0);
    
    enum Mode : Int{
        case convertAll = 0
        case convertOne = 1
        case restoreAll = 2
        case previewOne = 3
        case clearAll = 4
    }
    let mode = BehaviorSubject<Mode>(value: .convertAll);
    
    enum State : Int{
        case ready = 0
        case running = 1
        case stopped = 2
        case completed = 3
    }
    
    let state = BehaviorSubject<State>(value: .ready);
    func setState(_ value: State){
        self.state.onNext(value);
    }
    var isProcessing : Observable<Bool>{
        return self.state.map({ (state) -> Bool in
            return state == .running;
        })
    }
    
    var isConvertingOne : Bool{
        return try! self.mode.value() == .convertOne;
    }
    var isRestoring : Bool{
        return try! self.mode.value() == .restoreAll;
    }
    var isStopped : Bool{
        return try! self.state.value() == .stopped;
    }
    var isCompleted : Bool{
        return try! self.state.value() == .completed;
    }
    var isConverting : Bool{
        return try! self.mode.value() == .convertAll;
    }
    var isRunning : Bool{
        return try! self.state.value() == .running;
    }
    var needToPreview : Bool{
        return try! self.mode.value() == .previewOne;
    }
    
    var disposeBag = DisposeBag();

    @IBOutlet weak var txt_targetNumber: UITextField!;
    @IBOutlet weak var lb_nameValue: UILabel!
    @IBOutlet weak var lb_deptValue: UILabel!
    @IBOutlet weak var lb_jobValue: UILabel!
    @IBOutlet weak var lb_orgValue: UILabel!
    @IBOutlet weak var optionTable: UITableView!
    @IBOutlet weak var templateViewContainer: UIView!
    var templateView : ContactTemplateViewController?{
        get{
            return self.templateViewContainer.viewController?.childViewController(type: ContactTemplateViewController.self);
        }
    }
    
    var modelController : WCMDataController = WCMDataController.shared;
    
    @IBOutlet weak var prog_target: LSCircleProgressView!
    @IBOutlet weak var lb_count: UILabel!
    @IBOutlet weak var lb_status: UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var stack_button: UIStackView!
    
    @IBOutlet weak var btn_generateTitle: UIButton!
    @IBOutlet weak var btn_Generate: UIButton!
    @IBOutlet weak var btn_Gen_Select: UIButton!
    var convertOneBag = DisposeBag();
    @IBAction func onClick_Gen_Select(_ button: UIButton) {
        guard !self.isRunning else{
            return;
        }
        
        self.convertOneBag = DisposeBag();
        self.setState(.running);
        //button.isUserInteractionEnabled = false;
        self.selectContact(false);
    }
    
    @IBOutlet weak var btn_ClearPhotos: UIButton!
    var clearDisposeBag = DisposeBag();
    @IBAction func onClick_btn_ClearPhotos(_ button: UIButton) {
        guard !self.isRunning else{
            self.setProcessing(false);
            self.clearDisposeBag = DisposeBag();
            return;
        }
        
        RxContactController.shared.requestAccess()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filter{ [unowned self]result in
                return result && !self.isRunning
            }
            .flatMap({ (result) -> Observable<[CNContact]> in
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactImageDataKey as CNKeyDescriptor];
                
                return RxContactController.shared.requestContacts(keysToFetch);
            }).observeOn(MainScheduler.instance)
            .flatMap{ [unowned self]contacts in
                return self.askClearPhotos(contacts);
            }.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap({ [unowned self](contacts) -> Observable<CNContact> in
                self.mode.onNext(.clearAll);
                self.setProcessing(true);
                self.progressedCount.onNext(0);
                self.totalCount.onNext(contacts.count);
                
                return Observable<CNContact>.create({ (observer) -> Disposable in
                    contacts.forEach{ observer.onNext($0) }
                    observer.onCompleted();
                    
                    return Disposables.create();
                });
            }).delay(0.1, scheduler: MainScheduler.instance)
            .filter{ [unowned self]_ in self.isRunning }
            .flatMap{ [unowned self]contact in
                self.clearPhoto(contact)
            }
            .subscribe(onNext: { [unowned self]result in
                CNContact.localizedString(forKey: CNLabelPhoneNumberMain);
                CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone);
                CNContact.localizedString(forKey: CNLabelPhoneNumberMobile);
                
                //, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneNumbersKey,
                //print("load contacts. count[\(contacts.count)]");
                self.increaseProgressed();
            }, onError: { [unowned self](error) in
                print("load contacts error[\(error)]");
                self.openContactsSettings();
            }, onCompleted: { [unowned self] in
                self.setState(.completed);
            }).disposed(by: self.clearDisposeBag);
    }
    
    @IBOutlet weak var btn_Restore: UIButton!
    var restoreDisposeBag = DisposeBag();
    @IBAction func onClick_btn_Restore(_ sender: UIButton) {
        guard !self.isRunning else{
            self.setProcessing(false);
            self.restoreDisposeBag = DisposeBag();
            return;
        }
        
        //check there is stored data
        guard self.modelController.countForContacts() > 0 else {
            self.showAlert(title: self.msgs.getMsg(.ERROR), msg: self.msgs.getMsg(.ERR_NO_BAK_CONTACTS), actions: [UIAlertAction(title: self.msgs.getMsg(.OK), style: UIAlertActionStyle.default, handler: nil)], style: .alert);
            return;
        }
        
        RxContactController.shared.requestAccess()
            .filter{ [unowned self]result in
                result && !self.isRunning
            }
            .flatMap({ (result) -> Observable<[CNContact]> in
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                   CNContactNameSuffixKey as CNKeyDescriptor, CNContactDepartmentNameKey as CNKeyDescriptor,
                                   CNContactJobTitleKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor,
                                   CNContactImageDataKey as CNKeyDescriptor, CNContactNoteKey as CNKeyDescriptor];
                let identifiers = self.modelController.loadContacts().map{ $0.id! };
                
                return RxContactController.shared.requestContacts(keysToFetch, identifiers: identifiers);
            }).observeOn(MainScheduler.instance)
            .flatMap{ [unowned self]contacts in
                return self.askRestore(contacts)
            }.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap({ [unowned self](contacts) -> Observable<CNContact> in
                self.mode.onNext(.restoreAll);
                self.setProcessing(true);
                self.progressedCount.onNext(0);
                self.totalCount.onNext(contacts.count);
                
                return Observable<CNContact>.create({ (observer) -> Disposable in
                    contacts.forEach{ observer.onNext($0) }
                    observer.onCompleted();
                    
                    return Disposables.create();
                });
            }).delay(0.1, scheduler: MainScheduler.instance)
            .filter{ [unowned self]_ in self.isRunning }
            .flatMap({ [unowned self](contact) -> Observable<Bool> in
                return self.restore(contact);
            }).observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [unowned self](result) in
                //CNContact.localizedString(forKey: CNLabelPhoneNumberMain);
                //CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone);
                //CNContact.localizedString(forKey: CNLabelPhoneNumberMobile);
                
                self.increaseProgressed();
            }, onError: { [unowned self](error) in
                print("load contacts error[\(error)]");
                self.openContactsSettings();
            }, onCompleted: { [unowned self] in
                self.setState(.completed);
                self.modelController.reset();
                
                self.showFullAD();
            })
        .disposed(by: self.restoreDisposeBag);
    }
    
    @IBOutlet weak var btn_Preview: UIButton!
    @IBAction func onClick_Preview(_ sender: UIButton) {
        self.selectContact(true);
//        self.navigationController?.navigationBar.translucent = true;
    }

    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.translucent = false;
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.showAppleFullAD();
        //Crashlytics.sharedInstance().crash();
    }
    
    var googleFullAD : GADInterstitial?;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create constraint to hide bottom banner
        self.showBanner(visible: false);
        
        //Sets progressed count
        let cnt = WCMDataController.shared.countForContacts();
        self.totalCount.onNext(cnt);
        self.progressedCount.onNext(cnt);
        
        //google Bottom AD - leak?
        let req = GADRequest();
        if self.enableAds{
            self.bannerView.load(req);
        }
        
        //makes transparent navigation
        self.navigationController?.navigationBar.shadowImage = UIImage();
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);

        // Do any additional setup after loading the view.
        self.btn_Gen_Select.sizeToFit();
        self.btn_Gen_Select.titleLabel?.adjustsFontSizeToFitWidth = true;
        self.btn_Gen_Select.titleLabel?.minimumScaleFactor = 0.5;
        
        //Makes image of selected state follows tint color
        self.btn_generateTitle.imageView?.tintColor = UIColor.white;
        var selectedImage = self.btn_generateTitle.image(for: .selected);
        selectedImage = selectedImage?.withRenderingMode(.alwaysTemplate);
        
        //Makes title of selected state, selected == stop button == running
        self.btn_generateTitle.setImage(selectedImage, for: .selected);
        self.btn_generateTitle.setTitle(self.msgs[.STOP], for: .selected);
        self.btn_generateTitle.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        //self.lb_status.text = self.msgs[
        Observable.combineLatest(self.mode.asObservable(), self.state.asObservable(),
                                 resultSelector: { (mode : Mode, state : State) in
            return (mode, state)
        }).map { (mode, state) -> String in
            var value = "";
            
            switch state{
                case .ready:
                    break;
                case .stopped:
                    value = self.msgs[.STATUS_STOPPED];
                    break;
                default:
                    switch mode{
                    case .convertAll:
                        value = self.isRunning ? self.msgs[.STATUS_CONVERTING] :  self.msgs[.STATUS_CONVERTED];
                        break;
                    case .restoreAll:
                        value = self.isRunning ? self.msgs[.STATUS_RESTORING] :  self.msgs[.STATUS_RESTORED];
                        break;
                    case .clearAll:
                        value = self.isRunning ? self.msgs[.STATUS_CLEARING] :  self.msgs[.STATUS_CLEARED];
                        break;
                    default:
                        break;
                    }
                break;
            }
            
            return value;
        }.asDriver(onErrorJustReturn: "")
        .drive(self.lb_status.rx.text)
        .disposed(by: self.disposeBag);
        
        self.isProcessing.asObservable().asDriver(onErrorJustReturn: false)
            .map{ !$0 }
            .drive(self.btn_ClearPhotos.rx.isEnabled)
            .disposed(by: self.disposeBag);
        
        self.isProcessing.asObservable().asDriver(onErrorJustReturn: false)
            .map{ !$0 }
            .drive(self.btn_Preview.rx.isEnabled)
            .disposed(by: self.disposeBag);
        
        self.isProcessing.asObservable().asDriver(onErrorJustReturn: false)
            .map{ !$0 }
            .drive(self.btn_Restore.rx.isEnabled)
            .disposed(by: self.disposeBag);
        
        self.isProcessing.asObservable().asDriver(onErrorJustReturn: false)
            .map{ !$0 }
            .drive(self.btn_Gen_Select.rx.isEnabled)
            .disposed(by: self.disposeBag);
        
        self.isProcessing.asObservable().asDriver(onErrorJustReturn: false)
            .drive(self.btn_generateTitle.rx.isSelected)
            .disposed(by: self.disposeBag);
        
        // MARK: binding progress
        Observable.combineLatest(self.progressedCount.asObservable(), self.totalCount.asObservable(), resultSelector: { (progress: Int, total: Int) in
            return (progress, total);
        }).subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
        .asDriver(onErrorJustReturn: (0,0))
        .map { (count) -> Float in
            var p = count.0;
            let cnt = count.1;
            //Reverses count if being restore
            if self.isRestoring{
                p = cnt - p;
            }
            
            guard cnt > 0 && p > 0 else{
                return 1.0;
            }
            
            print("progress calc \(p) / \(cnt)");
            return Float(p) / Float(cnt);
        }.drive(self.prog_target.rx.progress)
        .disposed(by: self.disposeBag);
        
        self.progressedCount.asObserver().map({ (count) -> String in
            print("update progress count[\(count)]");
            return count.description;
        })
        .asDriver(onErrorJustReturn: "0")
        .drive(self.lb_count.rx.text)
        .disposed(by: self.disposeBag);
    }
    
    var generateDisposeBag = DisposeBag();
    @IBAction func onClick_btn_Generate(_ button: UIButton) {
        guard !self.isRunning else{
            self.setProcessing(false);
            self.generateDisposeBag = DisposeBag();
            return;
        }
        
        RxContactController.shared.requestAccess()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .filter{ [unowned self]result in
                result && !self.isRunning
            }
            .flatMap({ (result) -> Observable<[CNContact]> in
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                   CNContactNameSuffixKey as CNKeyDescriptor, CNContactDepartmentNameKey as CNKeyDescriptor,
                                   CNContactJobTitleKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor,
                                   CNContactImageDataKey as CNKeyDescriptor, CNContactNoteKey as CNKeyDescriptor];
                
                return RxContactController.shared.requestContacts(keysToFetch);
            }).flatMap({ [unowned self](contacts) -> Observable<CNContact> in
                self.mode.onNext(.convertAll);
                self.setProcessing(true);
                self.progressedCount.onNext(0);
                self.totalCount.onNext(contacts.count);
                
                return Observable<CNContact>.create({ (observer) -> Disposable in
                    contacts.forEach{ observer.onNext($0) }
                    observer.onCompleted();
                    
                    return Disposables.create();
                });
            }).delay(0.1, scheduler: MainScheduler.instance)
            .filter{ [unowned self]_ in self.isRunning }
            .flatMap({ [unowned self](contact) -> Observable<Bool> in
                //usleep(10)

                return self.convert(contact);
            }).observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            //.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [unowned self](result) in
                print("converting has been completed. result[\(result)]");
                //self.generate(contacts);
                //print("load contacts. count[\(contacts.count)]");
                self.increaseProgressed();
            }, onError: { [unowned self](error) in
                self.setProcessing(false);
                print("load contacts error[\(error)]");
                self.openContactsSettings();
            }, onCompleted: { [unowned self] in
                print("converting all has been completed");
                self.setState(.completed);
                self.modelController.reset();
                
                guard !self.isConvertingOne else{
                    self.showAlert(title: "Notification".localized(), msg: "Converting has been completed".localized(), actions: [UIAlertAction.init(title: "OK".localized(), style: .default, handler: nil)], style: .alert);
                    return;
                }
                
                self.showFullAD();
            }).disposed(by: self.generateDisposeBag);
    }
    
    func toggleContraint(value : Bool, constraintOn : NSLayoutConstraint, constarintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constarintOff.isActive = !value;
        }else{
            constarintOff.isActive = !value;
            constraintOn.isActive = value;
        }
    }
    
    /**
        Toggles banner
    */
    private func showBanner(visible: Bool){
        self.toggleContraint(value: visible, constraintOn: constraint_bottomBanner_Bottom, constarintOff: constraint_bottomBanner_Top);
        
        if visible{
            print("show banner");
        }else{
            print("hide banner");
        }
        self.bannerView.isHidden = !visible;
    }
    
    /// MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.showBanner(visible: true);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("banner error -  \(error)");
        self.showBanner(visible: false);
    }
    
    fileprivate func openContactsSettings(){
        self.showAlert(title: self.msgs[.ERROR], msg: self.msgs[.MSG_PLEASE_ALLOW_APP_CONTACTS], actions: [UIAlertAction(title: self.msgs[.SETTINGS], style: UIAlertActionStyle.default, handler: { (act) in
            UIApplication.shared.openSettings()
        }),UIAlertAction.init(title: self.msgs[.OK], style: UIAlertActionStyle.default, handler: nil)], style: UIAlertControllerStyle.alert);
    }
    
    fileprivate func showFullAD(){
        if self.enableAds{
            GADInterstialManager.shared?.show(true);
        }
    }
    
    /**
        Toggles information of the contact
    */
    func applyToggleInfos(_ template : ContactTemplateViewController){
        for (i, cell) in (self.optionTable.visibleCells as! [BaseOptionCell]).enumerated() {
            let type = ContactTemplateViewController.InfoType(rawValue: i);
            switch(type!){
                case .photo:
                    template.useThumbNail = cell.optionValue;
                    break;
                default:
                    break;
            }
        }
    }
    
    /**
        Disabled
        Checks if there is any option
    */
    func checkAndShowAlertNeedOption() -> Bool{
        var value = true;
        var optionEnabled = false;
        
        for cell in (self.optionTable.visibleCells as! [BaseOptionCell]){
            optionEnabled = optionEnabled || cell.optionValue;
        }
        
        guard !optionEnabled else{
            return value;
        }
        
        self.showAlert(title: "Error", msg: "Need an Enabled Option at least", actions: [UIAlertAction(title: "OK".localizedCapitalized, style: .default, handler: nil)], style: .alert);
        value = false;
        
        return value;
    }
    
    /**
        Returns indication whether if given contact has any data to generate image
         - parameter contact: Contact to check
         - returns: Indication whether if given contact has any data to generate image
    */
    func hasDataToGenerate(_ contact : CNContact) -> Bool{
        return (0...ContactTemplateViewController.InfoType.Count-1)
        .compactMap{ ContactTemplateViewController.InfoType(rawValue: $0) }
        .map { (type) -> Bool in
            var hasData = false;
            switch(type){
                case .photo:
                    hasData = contact.imageData != nil;
                    break;
                case .organization:
                    hasData = contact.organizationName.any;
                    break;
                case .department:
                    hasData = contact.departmentName.any;
                    break;
                case .jobTitle:
                    hasData = contact.jobTitle.any;
                    break;
            }
            
            return hasData;
        }.contains(true);
    }
    
    /**
        Generate image for give list of contact
         - parameter contacts: List of contact to generate image
    */
    fileprivate func generate(_ contact : CNMutableContact) -> OriginalContract?{
        var image : UIImage?;
        
        // MARK: Generate Image for call receiving
        self.templateView?.showAllInfos();
        let original = self.applyToTemplate(self.templateView!, contact: contact);
        //skip generating image if there is no org, dept, job
        if self.hasDataToGenerate(contact) {
            self.updateStep(.createImage);
            image = self.templateView?.view.renderImage();
            if image != nil{
                contact.imageData = UIImagePNGRepresentation(image!);
            }
            
            //Store generated image
            original?.generatedImage = contact.imageData;
        }else{
            original?.generatedImage = nil;
            contact.imageData = original?.imageData as Data?;
        }
        
        return original
    }
    
    fileprivate func convert(_ contact: CNContact) -> Observable<Bool>{
        var value = Observable<Bool>.just(false);
        self.updateStep(.ready);
        print("converting... \(contact.fullName ?? "")");
        
        //Check has phone number? No, need to generate for setting phone number later.
        //self.printContact(contact);
        
        // creates clone of contact to modify
        guard let target = contact.mutableCopy() as? CNMutableContact else{
            return value;
        }
        
        // MARK: Generate Image for call receiving
        self.templateView?.showAllInfos();
        let original = self.generate(target);
        
        // MARK: Create Index into note(memo) to support finding with cho-seong
        self.updateStep(.createIndex);
        self.generateIndex(target, original: original);
        
        self.updateStep(.saveContact);
        value = RxContactController.shared.save(target);
        self.modelController.saveChanges();
        self.modelController.reset();
        
        self.updateStep(.saveData);
        return value;
    }
    
    /**
        Opens preview screen for receiving call
         - parameter target: contact to preview
    */
    func preview(_ target : CNContact){
        guard let template = self.storyboard?.instantiateViewController(withIdentifier: "ContactTemplateViewController") as? ContactTemplateViewController else{
            return;
        }
        
        template.isPreviewMode = true;
        self.applyToggleInfos(template);
        
        let temp = target.mutableCopy() as? CNMutableContact;
        self.generateIndex(temp!, original: nil);
        self.applyToTemplate(template, contact: temp!, needBackup: false);
        
        self.navigationController?.pushViewController(template, animated: true);
        //Shows navigation bar to back home
        self.navigationController?.navigationBar.isHidden = false;
        self.modelController.reset();
    }
    
    /**
        Opens view controller lists of contact to select
         - parameter needPreview: indication whether to preview, not to apply
    */
    func selectContact(_ needToPreview : Bool = false){
        self.mode.onNext(needToPreview ? .previewOne : .convertOne);
        
        //prepares native view controller lists of contact
        let picker = CNContactPickerViewController();
        picker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactImageDataKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactNoteKey];
        picker.delegate = self;

        self.present(picker, animated: true, completion: nil);
    }
    
    /**
        Show warning alert to clear all photos from given contacts
         - parameter contacts: contacts to remove photo
    */
    fileprivate func askClearPhotos(_ contacts : [CNContact]) -> Observable<[CNContact]>{
        return Observable<[CNContact]>.create { (observer) -> Disposable in
            self.showAlert(title: self.msgs.getMsg(WCMMessageManager.MassageName.WARN),
                           msg: self.msgs.getMsg(WCMMessageManager.MassageName.WARN_CLEAR_PHOTOS_MSG),
                           actions: [UIAlertAction(title: self.msgs.getMsg(WCMMessageManager.MassageName.WARN_CLEAR_PHOTOS_CLEAR), style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                            observer.onNext(contacts);
                            observer.onCompleted();
                           }), UIAlertAction(title: self.msgs.getMsg(WCMMessageManager.MassageName.CANCEL), style: UIAlertActionStyle.cancel, handler: nil)],
                           style: UIAlertControllerStyle.actionSheet);
            
            return Disposables.create();
        }
    }
    
    fileprivate func clearPhoto(_ contact : CNContact) -> Observable<Bool>{
        var value : Observable<Bool>;
        guard let target = contact.mutableCopy() as? CNMutableContact else{
            return Observable<Bool>.just(false);
        }
        
        self.updateStep(.ready);
        print("############### clear contact ################");
        
        self.updateStep(.findOriginal);
        
        //clear images
        self.updateStep(.removeImage);
        target.imageData = nil;
        
        self.updateStep(.saveContact);
        value = RxContactController.shared.save(target);
        
        self.updateStep(.saveData);
        return value
    }
    
    /**
        Insert index into memo to support searching by cho-seong
         - parameter contact: contact to insert memo
         - parameter original: original data backed up for contact
    */
    func generateIndex(_ contact : CNMutableContact, original : OriginalContract?){
        //Sets suffix to display Full Description
        if (original?.generatedSuffix ?? "") != contact.nameSuffix{
            original?.suffix = contact.nameSuffix;
        }
        
        //Sets original suffix before get full name
        contact.nameSuffix = original?.suffix ?? "";
        
        //Sets nickname if nickname has been changed since generating
        if (original?.generatedNickname ?? "") != contact.nickname{
            original?.nickname = contact.nickname;
        }
        
        let fullDesc = contact.fullName ?? "";
        var jobDesc = "";
        
        if !contact.organizationName.isEmpty{
            jobDesc += "\(contact.organizationName)";
        }
        if !contact.departmentName.isEmpty{
            jobDesc += "/\(contact.departmentName)";
        }
        if !contact.jobTitle.isEmpty{
            jobDesc += "/\(contact.jobTitle)";
        }
        
        //create new suffix if the contact doesn't have original suffix
        if contact.nameSuffix.isEmpty {
            original?.generatedSuffix = " \(jobDesc)";
            contact.nameSuffix = original?.generatedSuffix ?? "";
        }
        
        /** create new nickname if the contact doesn't have original nickname
            new nicknamed = full name + job description
        */
        if (original?.nickname ?? "").isEmpty {
            original?.generatedNickname = " \(fullDesc) \(jobDesc)";
            contact.nickname = original?.generatedNickname ?? "";
        }
        
        let choSeongs = (fullDesc + jobDesc).getKoreanChoSeongs() ?? "";
        
        if choSeongs.any {
            
            let note = contact.note;
            //Gets position for choSeongs
            let range = note.range(byTag: self.WhoCallMeSearchTag);
            var originalNoteHigh = "";
            var originalNoteLow = "";
            
            //Gets original note if search tag has been found in it
            if range != nil{
                originalNoteHigh = String(note[...range!.lowerBound]);
                originalNoteLow = String(note[range!.upperBound...]);
            }else{
                originalNoteHigh = note;
            }
            
            if originalNoteHigh.last != "\n".last{
               originalNoteHigh = originalNoteHigh + "\n\n";
            }
            
            //Inserts cho-seongs into memo by wrapping tag
            contact.note = ("\(originalNoteHigh)\n\(choSeongs.wrap(byTag: WhoCallMeSearchTag))\n\(originalNoteLow)");
            
            print("choSeongs[\(choSeongs)]");
        }
    }
    
    /**
        Restores original name and memo of given contact by stored data
    */
    func restoreIndex(_ contact : CNMutableContact, original : OriginalContract?){
        // this method only works when original data specified
        guard original != nil else{
            return;
        }

        // MARK: Restore to original suffix
        if original?.generatedSuffix != contact.nameSuffix{
            original?.generatedSuffix = contact.nameSuffix;
        }else{
            print("suffix[\(contact.namePrefix)] => original suffix[\(original?.suffix ?? "")]");
            contact.nameSuffix = original?.suffix ?? "";
        }
        
        // MARK: Restore to original nickname
        if original?.generatedNickname != contact.nickname{
            original?.generatedNickname = contact.nickname;
        }else{
            print("nickname[\(contact.nickname)] => original nickname[\(original?.nickname ?? "")]");
            contact.nickname = original?.nickname ?? "";
        }
        
        // MARK: Restores note(memo)
        let note = contact.note;
        //Gets position for choSeongs
        let range = note.range(byTag: self.WhoCallMeSearchTag);
        var originalNoteHigh = "";
        var originalNoteLow = "";
        
        if range != nil{
            originalNoteHigh = String(note[...range!.lowerBound]);
            originalNoteLow = String(note[range!.upperBound...]);
            
            contact.note = "\(originalNoteHigh) \(originalNoteLow)";
        }
    }
    
    /**
        Restores contacts to original data before converted
         - parameter contacts: contacts to restore
    */
    fileprivate func askRestore(_ contacts : [CNContact]) -> Observable<[CNContact]>{
        return Observable<[CNContact]>.create({ [unowned self](observer) -> Disposable in
            self.showAlert(title: self.msgs[.WARN],
                           msg: self.msgs[.WARN_RESTORE_CONTACTS_MSG],
                           actions: [UIAlertAction(title: self.msgs[.WARN_RESTORE_CONTACTS_RESTORE], style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
                            observer.onNext(contacts);
                            observer.onCompleted();
                           }), UIAlertAction(title: self.msgs[.CANCEL], style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                            observer.onCompleted();
                           })],
                           style: UIAlertControllerStyle.actionSheet);
            
            return Disposables.create();
        })
    }
    
    fileprivate func restore(_ contact : CNContact) -> Observable<Bool> {
        var value : Observable<Bool> =  Observable<Bool>.just(false);
        print("############### contact ################")
        self.printContact(contact);
        
        guard let target = contact.mutableCopy() as? CNMutableContact else{
            return value;
        }
        
        /// MARK : Restore to original image
        let original = self.originalContactToRestore(target);
        
        /// MARK : Removing Index
        self.updateStep(.removeIndex);
        self.restoreIndex(target, original: original);
        
        if original?.isModified != true {
            target.imageData = original?.imageData as Data?;
        }
        
        self.updateStep(.saveContact);
        value = RxContactController.shared.save(target);
        
        self.updateStep(.saveData);
        if original != nil{
            self.modelController.removeContract(original!);
            self.modelController.saveChanges();
        }
        
        return value;
    }
    
    /**
        Saves modification of given contact
        - parameter contact: contact to save modification
        - returns: returns result of saving, if result is true, saving is success, otherwise it is failed.
    */
    func saveContact(_ contact : CNMutableContact) -> Bool{
        var value = false;
        //autoreleasepool { () -> () in
            let req = CNSaveRequest();
            
            do{
                req.update(contact);
                try self.contactStore.execute(req);
                value = true;
            }catch(let error){
                print("Contact saving is failed. error[\(error)]");
            }
        //}
        
        return value;
    }
    
    /**
        Updates progress on UI
         - parameter progress: current progressed count
         - parameter totalCount: total count to progress
    */
    func updateProgress(_ progress : Int, totalCount : Int){
        //ignore if select one not to progress all
        guard !self.isConvertingOne else{
            return;
        }
        
        self.progressedCount.onNext(progress);
        self.totalCount.onNext(totalCount);
    }
    
    /**
        Updates current step of current progress on UI
        this method is unusabled
    */
    fileprivate func _updateStep(_ step : GenerateStep){
        //self.prog_gen.progress = Float(step.hashValue) / Float(GenerateStep.Count);
        var msg = "";
        switch(step){
            case .ready:
                break;
            case .backupOriginal:
                msg = self.msgs[.STATUS_BAK_DATA];
                break;
            case .findOriginal:
                msg = self.msgs[.STATUS_FIND_BAK_DATA];
                break;
            case .checkOriginal:
                msg = self.msgs[.STATUS_CHECK_BAK_DATA];
                break;
            case .createImage:
                msg = self.msgs[.STATUS_CREATE_IMAGE];
                break;
            case .createIndex:
                msg = self.msgs[.STATUS_CREATE_INDEX];
                break;
            case .saveContact:
                msg = self.msgs[.STATUS_SAVE_CONTACT];
                break;
            case .saveData:
                msg = self.msgs[.STATUS_SAVE_DATA];
                break;
            default:
                break;
        }
        
        _ = msg;
//        self.lb_genStatus.text = msg;
    }
    
    /**
        Wrapper for _updateStep to run in main queue
    */
    func updateStep(_ step : GenerateStep){
        return;
        /*DispatchQueue.main.syncInMain{
            self._updateStep(step);
        }*/
    }
    
    /**
        Toggles the processing state
    */
    func setProcessing(_ value : Bool){
        guard !self.isConvertingOne else{
            return;
        }
        
        if !value{
            self.state.onNext(.stopped);
        }else{
            self.state.onNext(.running);
        }
    }
    
    /**
        Applies given contact to image template
    */
    @discardableResult
    fileprivate func applyToTemplate(_ template : ContactTemplateViewController, contact : CNContact, needBackup : Bool = true) -> OriginalContract?{
        //Gets original data from Database
        self.updateStep(.findOriginal);
        var originalContact = self.modelController.getContact(contact.identifier);
        //Indication to update original image
        var needUpdateOriginalImage = false;
        
        //if there is original data
        if originalContact != nil{
            //if original data has image, load it, otherwise set to nil
            var originalImage = originalContact?.imageData != nil ? UIImage(data: originalContact!.imageData!) : nil;
            template.originalImage = originalImage;
            print("load original image. id[\(originalContact?.id ?? "")] image[\(template.originalImage?.description ?? "")] len[\(originalContact!.imageData?.count.description ?? "")]");

            self.updateStep(.checkOriginal);
            //if original image is inserted or deleted
            needUpdateOriginalImage = (originalContact?.imageData != nil) != (contact.imageData != nil);
            
            var beforeImage : UIImage?;
            //it is not neccesary to update, but check size of image
            if !needUpdateOriginalImage && contact.imageData != nil{
                beforeImage = originalContact!.generatedImage != nil ? UIImage(data: originalContact!.generatedImage!)! : nil;
                needUpdateOriginalImage = beforeImage?.size != UIImage(data: contact.imageData!)?.size;
            }
        
            //if original image has been changed
            if needUpdateOriginalImage{
                print("update original imageData by new");
                //image is nil => change original image to nil
                if contact.imageData == nil{
                    originalContact?.imageData = nil;
                    originalImage = nil;
                }else{
                    if originalContact?.generatedImage?.elementsEqual(contact.imageData!) == true{
                        originalImage = UIImage();
                    }else{
                        //update original image of database
                        originalContact?.imageData = contact.imageData;
                        originalImage = UIImage(data: contact.imageData!);
                    }
                }

                template.originalImage = originalImage;
            }
        } else if needBackup {
            //create new backup data
            originalContact = self.modelController.createContact();
            originalContact?.id = contact.identifier;
            if contact.imageData != nil{
                self.updateStep(.backupOriginal);
                originalContact?.imageData = contact.imageData;
            }
        }else{
            if contact.imageData != nil{
                template.originalImage = UIImage(data: contact.imageData!);
            }
        }
        
        template.contact = contact;
        template.refresh();
        
        return originalContact;
    }
    
    /**
        Creates entity to back up original data of given contact
         - parameter contact: contact to back up
         - parameter needSync: ??
    */
    fileprivate func originalContactToRestore(_ contact : CNContact) -> OriginalContract?{
        //get original imageData from Database
        self.updateStep(.findOriginal);
        let originalContact = self.modelController.getContact(contact.identifier);
        var needToUpdateOriginalImage = false;
        
        if originalContact != nil{
            print("load original image. id[\(originalContact?.id ?? "")] len[\(originalContact!.imageData?.count.description ?? "")]");
            
            self.updateStep(.checkOriginal);
            needToUpdateOriginalImage = (originalContact?.imageData != nil) != (contact.imageData != nil);
            
            var beforeImage : UIImage?;
            //checks if photo size was changed
            if !needToUpdateOriginalImage && contact.imageData != nil{
                beforeImage = originalContact!.generatedImage != nil ? UIImage(data: originalContact!.generatedImage!)! : nil;
                needToUpdateOriginalImage = beforeImage?.size != UIImage(data: contact.imageData!)?.size;
            }
            
            if needToUpdateOriginalImage{
                print("update original imageData by new");
                if contact.imageData == nil{
                    originalContact?.imageData = nil;
                }else{
                    originalContact?.imageData = contact.imageData;
                }
                
                //Sets flag on to update
                originalContact?.isModified = true;
            }
        }
        
        return originalContact;
    }
    
    func printContact(_ contact : CNContact){
        print("identifier[\(contact.identifier)]");
        print("\(CNContact.localizedString(forKey: CNContactGivenNameKey))[\(contact.fullName ?? "")]");
        print("\(CNContact.localizedString(forKey: CNContactOrganizationNameKey))[\(contact.organizationName)]");
        print("\(CNContact.localizedString(forKey: CNContactDepartmentNameKey))[\(contact.departmentName)]");
        print("\(CNContact.localizedString(forKey: CNContactJobTitleKey))[\(contact.jobTitle)]");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// MARK : UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionIndex.Count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var value : UITableViewCell?;
        
        switch(OptionIndex(rawValue: indexPath.row)!){
            case .thumnail:
                value = self.optionTable.dequeueReusableCell(withIdentifier: Cell_Ids.OptionPhotoCell) as? BaseOptionCell;
                break;
//            case .Organization:
//                var cell = self.optionTable.dequeueReusableCellWithIdentifier(LSUIUtil.getClassName(OptionOrgCell.self)) as? OptionOrgCell;
//                value = cell;
//
//                break;
//            case .Department:
//                var cell = self.optionTable.dequeueReusableCellWithIdentifier(LSUIUtil.getClassName(OptionDeptCell.self)) as? OptionDeptCell;
//                value = cell;
//
//                break;
//            case .JobTitle:
//                var cell = self.optionTable.dequeueReusableCellWithIdentifier(LSUIUtil.getClassName(OptionJobCell.self)) as? OptionJobCell;
//                value = cell;
//
//                break;
        }
        
        if value == nil{
            value = UITableViewCell();
        }
        return value!;
    }

    /// MARK : UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.optionTable.cellForRow(at: indexPath) as? BaseOptionCell;
        cell?.optionValue = !cell!.optionValue;
        
//        switch(OptionIndex(rawValue: indexPath.row)!){
//            case .Photo:
//                
//                break;
//            default:
//                break;
//        }
    }
    
    /// MARK : CNContactPickerDelegate
//    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
//        print("single select \(contact)");
//    }
    
//    func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
//        
////        print("sibal");
//        print("didSelectContacts \(contacts)");
//        guard contacts.count > 0 else{
//            return;
//        }
//        
//        self.generate(contacts);
//    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if self.needToPreview{
            self.preview(contact);
        }else{
            Observable<CNContact>.just(contact)
                .delay(0.1, scheduler: MainScheduler.instance)
                .flatMapLatest({ [unowned self](contact) -> Observable<Bool> in
                    return self.convert(contact);
                })
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [unowned self](contact) in
                    self.setState(.completed);
                }, onCompleted: { [unowned self] in
                    self.btn_Gen_Select.isUserInteractionEnabled = true;
                }).disposed(by: self.convertOneBag);
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        //self.mode.onNext(<#T##element: MainViewController.Mode##MainViewController.Mode#>)
        self.state.onNext(.ready);
        self.modelController.reset();
    }
    
//    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperties contactProperties: [CNContactProperty]) {
//        print("property selected \(contactProperties)");
//        
//        var contacts : [CNContact] = [];
//        for prop in contactProperties{
//            contacts.append(prop.contact);
//        }
//        
//        print("property selected end");
//        
//        self.generate(contacts);
//    }
    
//    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
//        print("didSelectContactProperty \(contactProperty)");
//    }
    
//    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
//        
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
