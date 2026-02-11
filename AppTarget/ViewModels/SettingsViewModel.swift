import Foundation
import Observation
import Domain
import UseCase

/// 設定画面のロジックを管理する ViewModel。
@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - State

    private(set) var subjects: [Subject] = []
    var slotsPerDay: Int = 5
    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let subjectUseCase: SubjectUseCase
    private let settingsUseCase: SettingsUseCase
    private let userId: String

    // MARK: - Init

    init(
        subjectUseCase: SubjectUseCase,
        settingsUseCase: SettingsUseCase,
        userId: String
    ) {
        self.subjectUseCase = subjectUseCase
        self.settingsUseCase = settingsUseCase
        self.userId = userId
    }

    // MARK: - Actions

    func loadSettings() async {
        isLoading = true
        errorMessage = nil

        do {
            subjects = try await subjectUseCase.fetchSubjects(userId: userId)
            slotsPerDay = try await settingsUseCase.fetchSlotsPerDay(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveSlotsPerDay() async {
        do {
            try await settingsUseCase.saveSlotsPerDay(userId: userId, count: slotsPerDay)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveSubject(_ subject: Subject) async {
        do {
            try await subjectUseCase.saveSubject(userId: userId, subject: subject)
            subjects = try await subjectUseCase.fetchSubjects(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteSubject(_ subject: Subject) async {
        do {
            try await subjectUseCase.deleteSubject(userId: userId, subjectId: subject.id)
            subjects = try await subjectUseCase.fetchSubjects(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
