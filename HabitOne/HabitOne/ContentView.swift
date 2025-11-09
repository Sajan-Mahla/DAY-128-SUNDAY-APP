//
//  ContentView.swift
//  HabitOne
//
//  Created by SAJAN  on 09/11/25.
//

import SwiftUI
import Combine

// MARK: - Model
struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var emoji: String
    var isCompleted: Bool = false
    var lastCompletedDate: Date? = nil
}

// MARK: - ViewModel
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet { saveHabits() }
    }
    
    private var timerCancellable: AnyCancellable?
    private let habitsKey = "habits_key"
    
    init() {
        loadHabits()
        startDailyResetChecker()
    }
    
    func addHabit(title: String, emoji: String) {
        let newHabit = Habit(title: title, emoji: emoji)
        habits.append(newHabit)
    }
    
    func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
            habits[index].lastCompletedDate = Date()
        }
    }
    
    // MARK: - Daily Reset Logic
    private func startDailyResetChecker() {
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.resetIfNewDay()
            }
    }
    
    private func resetIfNewDay() {
        let calendar = Calendar.current
        for i in habits.indices {
            if let last = habits[i].lastCompletedDate,
               !calendar.isDateInToday(last) {
                habits[i].isCompleted = false
            }
        }
    }
    
    // MARK: - Persistence
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}

// MARK: - View
struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showAddHabit = false
    
    var body: some View {
        NavigationView {
            VStack {
                header
                
                if viewModel.habits.isEmpty {
                    Text("No habits yet 🫠\nTap + to add one")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.habits) { habit in
                            HStack {
                                Text(habit.emoji)
                                    .font(.title2)
                                Text(habit.title)
                                    .font(.headline)
                                Spacer()
                                Button {
                                    withAnimation {
                                        viewModel.toggleHabit(habit)
                                    }
                                } label: {
                                    Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(habit.isCompleted ? .green : .gray)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Color(.systemGray6))
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    progressView
                }
            }
            .navigationTitle("HabitOne")
            .toolbar {
                Button(action: { showAddHabit.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }
    
    private var header: some View {
        VStack {
            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressView: some View {
        let completed = viewModel.habits.filter { $0.isCompleted }.count
        let total = max(viewModel.habits.count, 1)
        let progress = Double(completed) / Double(total)
        
        return VStack {
            Text("Progress: \(Int(progress * 100))%")
                .font(.subheadline)
            ProgressView(value: progress)
                .tint(.green)
                .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

// MARK: - Add Habit Sheet
struct AddHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var emoji = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit name", text: $title)
                TextField("Emoji (🔥💪🧠)", text: $emoji)
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.isEmpty, !emoji.isEmpty else { return }
                        viewModel.addHabit(title: title, emoji: emoji)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
