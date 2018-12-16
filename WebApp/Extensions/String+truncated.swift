extension String {
    var truncationLimit: Int { return 50 }

    func truncated() -> String {
        guard count > truncationLimit else {
            return self
        }
        return "\(prefix(truncationLimit)) ..."
    }
}
