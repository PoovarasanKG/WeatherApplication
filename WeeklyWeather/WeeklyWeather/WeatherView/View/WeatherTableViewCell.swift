import UIKit

class WeatherTableViewCell: UITableViewCell  {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var cellsiusLabel: UILabel!
    @IBOutlet weak var dayHighlightImageView: UIImageView!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
