import UIKit
import SnapKit
import Nuke

class GistTableViewCell: UITableViewCell, Reusable {

    var gist: Gist? {
        didSet {
            guard let gist = gist else { return }
            Nuke.loadImage(with: gist.owner.avatarUrl, into: iconImageView)
            gistLabel.text = gist.files.first?.key ?? ""
            usernameLabel.text = "@\(gist.owner.login)"
            if let desc = gist.description, !desc.isEmpty {
                descriptionLabel.text = desc
            } else {
                descriptionLabel.text = "No Description"
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .primary_main
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    private lazy var gistLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private func setupSubviews() {
        [iconImageView, gistLabel, descriptionLabel, usernameLabel].forEach(contentView.addSubview)
        iconImageView.snp.makeConstraints {
            $0.height.width.equalTo(60)
            $0.top.equalToSuperview().inset(16)
            $0.left.equalToSuperview().inset(24)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
        gistLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(20)
            $0.right.equalToSuperview().inset(20)
            $0.top.equalTo(iconImageView).offset(2)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(gistLabel.snp.bottom).offset(2)
            $0.left.right.equalTo(gistLabel)
        }
        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(gistLabel)
            $0.right.equalToSuperview().inset(24)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(2)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}
