import Foundation

protocol LearningFlowServiceProtocol: AnyObject {
    func modules() -> [LearningModule]
    func nodes(in moduleID: String) -> [LearningNode]
    func currentAvailableNode(in moduleID: String) -> LearningNode?
    @discardableResult func markNodeCompleted(_ nodeID: String, in moduleID: String) -> LearningNode?
    func progress(for moduleID: String) -> Double
}
