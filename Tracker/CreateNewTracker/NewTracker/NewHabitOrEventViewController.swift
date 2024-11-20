//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by big stepper on 09/10/2024.
//

import UIKit


protocol TimeTableViewControllerDelegate: AnyObject {
    func timeTable(_ timeTable: Set<Weekday>)
}

protocol CategoryViewModelDelegate: AnyObject {
    func category(_ category: String)
}


final class NewHabitOrEventViewController: UIViewController {
    
    //MARK: - Init
    
    init(
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         isHabit: Bool,
         dataProvider: DataProviderProtocol
    ) {
        self.dataProvider = dataProvider
        self.isHabit = isHabit
        self.tableCellTitle = isHabit ? [
            NSLocalizedString("category", comment: ""),
            NSLocalizedString("timetable", comment: "")
        ] : [
            NSLocalizedString("category", comment: "")
        ]
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addPaddingToTextField()
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .ypGray.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .black
        textField.placeholder = NSLocalizedString("textfieldplaceholder", comment: "")
        textField.delegate = self
        return textField
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.text = NSLocalizedString("limit", comment: "")
        label.isHidden = true
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle(
            NSLocalizedString("cancel", comment: ""),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .ypDarkGray
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.setTitle(
            NSLocalizedString("create", comment: ""),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, warningLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorOrEmojiHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: collectionHeaderIdentifier)
        collectionView.register(EmojiCollectionViewCell.self,
                                forCellWithReuseIdentifier: emojiCollectionIdentifier)
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorOrEmojiHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: collectionHeaderIdentifier)
        collectionView.register(ColorCollectionViewCell.self,
                                forCellWithReuseIdentifier: colorCollectionIdentifier)

        return collectionView
    }()
    
    private lazy var collectionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emojiCollectionView, colorCollectionView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 34
        stackView.alignment = .fill
        return stackView
    }()
    
    //MARK: - Properties
    
    weak var delegate: NewTrackerVCDelegate?
    
    private var dataProvider: DataProviderProtocol?
    
    private var viewModel: CategoryViewModelProtocol?

    private let collectionHeaderIdentifier = TrackerCollectionViewHeader.reuseIdentifier
    private let colorCollectionIdentifier = ColorCollectionViewCell.reuseIdentifier
    private let emojiCollectionIdentifier = EmojiCollectionViewCell.reuseIdentifier
    
    private let colors: [UIColor] = [
                                    .ypSelection1, .ypSelection2, .ypSelection3,
                                    .ypSelection4, .ypSelection5, .ypSelection6,
                                    .ypSelection7, .ypSelection8, .ypSelection9,
                                    .ypSelection10, .ypSelection11, .ypSelection12,
                                    .ypSelection13, .ypSelection14, .ypSelection15,
                                    .ypSelection16, .ypSelection17, .ypSelection18
                                    ]
    private let emojis: [String] = [
                                    "🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
                                    ]
    private var selectedColorIndex: IndexPath?
    private var selectedEmojiIndex: IndexPath?
                                    
    private var tableCellTitle: [String]
    
    private var trackerName: String = ""
    private var timeTable: Set<Weekday> = []
    private var selectedColor: UIColor = .clear
    private var selectedEmoji: String = ""
    
    //TODO: - add category selection
    private var categoryName: String = ""
    
    private var isHabit: Bool
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        guard let dataProvider else { return }
        
        let viewModel = CategoryViewModel(
            alertPresenter: AlertPresenter(),
            dataProvider: dataProvider,
            selectedCategory: self.categoryName
        )
        viewModel.delegate = self
        self.viewModel = viewModel
    }
    
    //MARK: - UI methods
    
    private func layoutButtonsInStackView() {
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 166)
        ])
    }
    
    func setupUI() {
        self.title = isHabit ? NSLocalizedString(
            "newhabit",
            comment: ""
        ) : NSLocalizedString(
            "newevent",
            comment: ""
        )
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubviews(textFieldStackView,
                               tableView,
                               collectionsStackView,
                               buttonsStackView)

        layoutButtonsInStackView()
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textFieldStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                                        constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -16),
            textFieldStackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                                    constant: 24),
            
            textField.heightAnchor.constraint(equalToConstant: 75),

            warningLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * tableCellTitle.count)),
            tableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            collectionsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionsStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            collectionsStackView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor,
                                                         constant: -40),
            collectionsStackView.heightAnchor.constraint(equalToConstant: 452),
                        
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    //MARK: - Methods
    
    private func enableCreateButton() {
        createButton.isEnabled = true
        createButton.backgroundColor = .black
    }
    
    private func checkIfAllFieldsAreFilled() {
        //TODO: - category check
        if isHabit {
            guard
                !trackerName.isEmpty,
                !timeTable.isEmpty,
                selectedColor != .clear,
                !selectedEmoji.isEmpty
            else { return }
        } else {
            guard
                !trackerName.isEmpty,
                selectedColor != .clear,
                !selectedEmoji.isEmpty
            else { return }
        }

        enableCreateButton()
    }
    
    //TODO: - category sprint 16
    private func createNewTracker() {
        let tracker = Tracker(id: UUID(),
                              name: self.trackerName,
                              color: self.selectedColor,
                              emoji: self.selectedEmoji,
                              timeTable: isHabit ? Array(self.timeTable) : [])
        
        dataProvider?.addTrackerToCategory(tracker: tracker, category: categoryName)
    }
    
    //MARK: - Obj-C methods
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        createNewTracker()
        dismiss(animated: true)
        delegate?.reloadCollectionView()
    }
}

//MARK: - TableView Datasource

extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tableCellTitle.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tableViewCell")
        
        cell.backgroundColor = .ypGray.withAlphaComponent(0.3)
        cell.accessoryType = .disclosureIndicator
        
        cell.detailTextLabel?.textColor = .ypDarkGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = tableCellTitle[0]
            cell.detailTextLabel?.text = categoryName
        case 1:
            cell.textLabel?.text = tableCellTitle[1]
            cell.detailTextLabel?.text = timeTable.count == 7 ? NSLocalizedString(
                "everyday",
                comment: ""
            ) : timeTable.map { $0.shortened }.joined(separator: ", ")
        default:
            break
        }
        
        cell.selectionStyle = .none
        if indexPath.row == tableCellTitle.count - 1 {
            cell.separatorInset = .init(top: 0,
                                        left: 0,
                                        bottom: 0,
                                        right: .greatestFiniteMagnitude)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        return cell
    }
}

//MARK: - TableView Delegate

extension NewHabitOrEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //TODO: - Category View Controller sprint 15
            guard let viewModel else { return }
            
            let categoryNC = UINavigationController(rootViewController: CategoryViewController(viewModel: viewModel))
            self.present(categoryNC, animated: true)
        case 1:
            let timeTableNC = UINavigationController(rootViewController: TimeTableViewController(delegate: self, timeTable: self.timeTable))
            self.present(timeTableNC, animated: true)
        default:
            break
        }
    }
}

//MARK: - UITextFieldDelegate

extension NewHabitOrEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count < 38 && text.count > 0 {
            self.trackerName = text
            checkIfAllFieldsAreFilled()
            warningLabel.isHidden = true
        } else if text.count > 38 {
            warningLabel.isHidden = false
        }
    }
}

//MARK: - TimeTableVC Delegate

extension NewHabitOrEventViewController: TimeTableViewControllerDelegate {
    func timeTable(_ timeTable: Set<Weekday>) {
        self.timeTable = timeTable
        tableView.reloadData()
        checkIfAllFieldsAreFilled()
    }
}

//MARK: - CategoryViewModelDelegate

extension NewHabitOrEventViewController: CategoryViewModelDelegate {
    func category(_ category: String) {
        self.categoryName = category
        tableView.reloadData()
        checkIfAllFieldsAreFilled()
    }
}

//MARK: - Collection View Data Source

extension NewHabitOrEventViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCollectionIdentifier,
                                                                for: indexPath) as? EmojiCollectionViewCell
                    else { return UICollectionViewCell() }

            cell.setupCell(with: emojis[indexPath.row])
            cell.setSelected(indexPath == selectedEmojiIndex)

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCollectionIdentifier,
                                                                for: indexPath) as? ColorCollectionViewCell
                    else { return UICollectionViewCell() }

            cell.setupCell(with: colors[indexPath.row])
            cell.setSelected(indexPath == selectedColorIndex)

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: collectionHeaderIdentifier,
            for: indexPath) as? ColorOrEmojiHeader
        else { return UICollectionReusableView() }
        
        if collectionView == colorCollectionView {
            header.configureHeader(text: NSLocalizedString("color", comment: ""))
            return header
        } else {
            header.configureHeader(text: NSLocalizedString("emoji", comment: ""))
            return header
        }
    }
}

//MARK: - Collection View Flow Layout

extension NewHabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let header: UICollectionReusableView
        
        if #available(iOS 18.0, *) {
            return CGSize(width: collectionView.bounds.width - 56, height: 18)
        } else {
            header = self.collectionView(collectionView,
                                                 viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                                 at: indexPath)
        }
        
        
        
        return header.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - Emoji and color selection
    
extension NewHabitOrEventViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.row]
            selectedColorIndex = indexPath
            colorCollectionView.reloadData()
            checkIfAllFieldsAreFilled()
        } else {
            selectedEmoji = emojis[indexPath.row]
            selectedEmojiIndex = indexPath
            emojiCollectionView.reloadData()
            checkIfAllFieldsAreFilled()
        }
    }
}
