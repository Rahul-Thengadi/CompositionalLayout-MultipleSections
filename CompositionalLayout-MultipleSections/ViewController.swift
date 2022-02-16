//
//  ViewController.swift
//  CompositionalLayout-MultipleSections
//
//  Created by Rahul Thengadi on 10/02/22.
//

import UIKit

class ViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case grid // 0
        case single // 1
        
        var columnCount: Int {
            switch self { // self represents the instance of enum
            case .grid:
                return 4 // 4 columns
            case .single:
                return 1 // 1 column
            }
        }
    }

    @IBOutlet weak var collectionView: UICollectionView! // default layout is Flow Layout
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int> // both has to conform to Hashable
    
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        // override the default layout from layout to compositional layout
        
        // if done programmatically
        // collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemBackground
        
    }

    private func createLayout() -> UICollectionViewLayout {
        // item
        // group
        // section
        // let layout = UICollectionViewCompositionalLayout(section: section)
        // return layout
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // find out what section we are working with
            guard let sectionType = Section(rawValue: sectionIndex) else {
                return nil
            }
            
            // how many colums
            let columns = sectionType.columnCount // 1 or 4 columns
            
            // crete the layout: item -> group -> section -> layout
            
            // what's the item's container? => group
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
            
            // what's the group's container? => section
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth (0.25)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns) // 1 or 4
            group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
    }
    
    
    private func configureDataSource() {
        
        // settig up the data source
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            // configure the cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
                fatalError("could not deque a LabelCell")
            }
            
            cell.textLabel.text = "\(itemIdentifier)"
            
            if indexPath.section == 0 { // first section
                cell.backgroundColor = .systemOrange
            } else {
                cell.backgroundColor = .systemGreen
            }
            
            return cell
        })
        
        // setual initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.grid, .single])
        snapshot.appendItems(Array(1...12), toSection: .grid)
        snapshot.appendItems(Array(13...20), toSection: .single)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

