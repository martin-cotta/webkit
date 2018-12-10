extension String {
    
    var truncationLimit: Int {
        get { return 50 }
    }
    
    func truncated() -> String {
        guard self.count > truncationLimit else {
            return self
        }
        return "\(self.prefix(truncationLimit)) ..."
    }
}
