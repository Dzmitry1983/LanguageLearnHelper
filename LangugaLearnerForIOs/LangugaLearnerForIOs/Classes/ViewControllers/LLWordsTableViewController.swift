//
//  LLWordsTableViewController.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2017-02-14.
//  Copyright © 2017 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class LLWordsTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
	var modelsArray = LLSQLWordsTableControllerModel()
	
	/*
	enum StudyWodrsType : Int {
	case all = 0
	case studying
	case studied
	}
*/
	
	@IBInspectable var studyingType:Int = 0
	
	
	
//	var collation:UILocalizedIndexedCollation!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}
	
	var countElements = 0
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.updateResult()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateResult()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.modelsArray.close()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    private func updateResult() {
        if let study = StudyWodrsType(rawValue: studyingType) {
            self.modelsArray.studyType = study
        }
        self.modelsArray.load()
        self.countElements = 0
        for i in 0..<self.modelsArray.count {
            self.countElements += self.modelsArray[i].count
        }
        self.tableView.reloadData()
    }
	
	func configureCollation() {
		
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.modelsArray.count
	}
	
	// fixed font style. use custom view (UILabel) if you want something different
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.modelsArray[section].name + "\t\t (\(self.modelsArray[section].count)/\(self.countElements))"
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.modelsArray[section].count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "WordStudyModel"
		let model = self.modelsArray[indexPath.section, indexPath.item]
		if tableView != self.tableView {
			let cellMod = UITableViewCell()
			cellMod.textLabel?.text = "\(model.word) (\(model.speech)) \(model.transcription), \(model.studyingType)"
			return cellMod
		}
		
		
		
		let returnValue:UITableViewCell
		if let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LLWordStudyTableViewCell {
            myCell.updateFrom(model, indexPath: indexPath)
			returnValue = myCell
		}
		else {
			let cellMod = UITableViewCell()
			cellMod.textLabel?.text = "\(model.word) (\(model.speech)) \(model.transcription), \(model.studyingType)"
			returnValue = cellMod
		}
		return returnValue
	}
	
	
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return self.studyingType > 0
	}
	
	
	
	
	// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the data source
			let model = self.modelsArray[indexPath.section, indexPath.item]
			if model.studyingType > 0 {
				model.studyingType -= 1
			}
			
			if self.modelsArray[indexPath.section].count > 1 {
				self.modelsArray.saveModel(model)
				self.modelsArray.update()
				tableView.deleteRows(at: [indexPath], with: .fade)
			}
			else {
				self.modelsArray.saveModel(model)
				self.modelsArray.update()
				tableView.reloadData()
			}
			
			
			
			
			
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(indexPath)
		
		let model = self.modelsArray[indexPath.section, indexPath.item]
		self.modelsArray.updateModel(model)
        
        let viewController = UIStoryboard(name: "LLDefenitionViewController", bundle: nil).instantiateInitialViewController()
        
        guard let viewController = viewController as? LLDefenitionViewController else {
            assertionFailure()
            return
        }
        
        viewController.wordModel = model
		self.navigationController?.pushViewController(viewController, animated:true)
		
	}
	
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
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	//MARK: - UISearchControllerDelegate
	func willPresentSearchController(_ searchController: UISearchController) {
		print("updateSearchResults")
	}
	
	
	public func didPresentSearchController(_ searchController: UISearchController) {
		print("didPresentSearchController")
	}
	
	
	public func willDismissSearchController(_ searchController: UISearchController) {
		print("willDismissSearchController")
	}
	
	
	public func didDismissSearchController(_ searchController: UISearchController) {
		print("didDismissSearchController")
	}
	
	
	// Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
	
	public func presentSearchController(_ searchController: UISearchController) {
		print("presentSearchController")
	}
	
	
	// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
	//MARK: - UISearchResultsUpdating
	public func updateSearchResults(for searchController: UISearchController) {
		print("updateSearchResults")
	}
	
	
	
	//MARK: - UISearchBarDelegate
	
	// return NO to not become first responder{
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool  {
		print("searchBarShouldBeginEditing")
		return true
	}
	
	// called when text starts editing
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		print("searchBarTextDidBeginEditing")
	}
	
	// return NO to not resign first responder
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		print("searchBarShouldEndEditing")
		return true
	}
	
	// called when text ends editing
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		print("searchBarTextDidEndEditing")
		
	}
	
	// called when text changes (including clear)
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print("textDidChange \(searchText)")
		if searchText.isEmpty && self.modelsArray.filterWord.isEmpty {
			return
		}
		if self.modelsArray.filterWord != searchText  {
			self.modelsArray.filterWord = searchText
			self.tableView.reloadData()
		}
		
	}
	
	// called before text changes
	func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		print("shouldChangeTextIn \(text)")
		return true
	}
	
	
	// called when keyboard search button pressed
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarSearchButtonClicked")
        searchBar.resignFirstResponder()
	}
	
	// called when bookmark button pressed
	func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarBookmarkButtonClicked")
        searchBar.resignFirstResponder()
	}
	
	// called when cancel button pressed
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarCancelButtonClicked")
		if !self.modelsArray.filterWord.isEmpty  {
			self.modelsArray.filterWord = ""
			self.tableView.reloadData()
		}
        searchBar.resignFirstResponder()
	}
	
	// called when search results button pressed
	func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
		print("searchBarResultsListButtonClicked")
        searchBar.resignFirstResponder()
	}
	
	
	
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		print("selectedScopeButtonIndexDidChange \(selectedScope)")
	}
}
