//
//  ContentView.swift
//  myBudget
//
//  Created by Iuri Vardosanidze on 03/11/2026.
//

import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let category: String
    let date: String
}

let expenseCategories = ["საკვები", "ტრანსპორტი", "გართობა", "სხვა"]

struct ContentView: View {
    @State private var expenses: [Expense] = [
        Expense(title: "სადილი", amount: 25.00, category: "საკვები", date: "3 ნოემბერი"),
        Expense(title: "ავტობუსი", amount: 2.00, category: "ტრანსპორტი", date: "2 ნოემბერი"),
        Expense(title: "კინო", amount: 30.00, category: "გართობა", date: "1 ნოემბერი")
    ]
    
    // Sheet გამოჩენის კონტროლი
    @State private var isShowingAddExpense = false
    
    // ხარჯების ჯამის გამოთვლა
    var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // ჯამის ბარათი (Header)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ამ თვის ხარჯი")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("ჯამი: \(totalAmount, specifier: "%.2f") ₾")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // ხარჯების სია ან ცარიელი მდგომარეობის შეტყობინება
                if expenses.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("ხარჯები ჯერ არ არის დამატებული")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List {
                        Section(header: Text("ხარჯები").font(.headline)) {
                            ForEach(expenses) { expense in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(expense.title)
                                            .font(.body)
                                            .bold()
                                        
                                        Text("\(expense.category) • \(expense.date)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(expense.amount, specifier: "%.2f") ₾")
                                        .bold()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("ჩემი ბიუჯეტი")
            // + ღილაკი ზედა კუთხეში
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // ხარჯის დამატების ფორმის გახსნა
            .sheet(isPresented: $isShowingAddExpense) {
                AddExpenseView { newExpense in
                    expenses.insert(newExpense, at: 0)
                }
            }
        }
    }
}

//  ხარჯის დამატების ფორმა AddExpenseView

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var selectedCategory: String = "საკვები"
    @State private var selectedDate: Date = Date()
    
    // შეცდომის შეტყობინების (Alert) ცვლადები
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // ვაგზავნით შეტყობინებას ახალი ხარჯის დასაბრუნებლად
    var onSave: (Expense) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("დასახელება")) {
                    TextField("მაგ. სადილი", text: $title)
                }
                
                Section(header: Text("თანხა")) {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("კატეგორია")) {
                    Picker("კატეგორია", selection: $selectedCategory) {
                        ForEach(expenseCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("თარიღი")) {
                    DatePicker("თარიღი", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("ახალი ხარჯი")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("გაუქმება") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("შენახვა") {
                        validateAndSave()
                    }
                }
            }
            
            .alert("შეცდომა", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // ველების შემოწმება და შენახვა
    private func validateAndSave() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //  ცარიელი დასახელების შემოწმება
        if trimmedTitle.isEmpty {
            alertMessage = "გთხოვთ შეიყვანოთ დასახელება."
            showAlert = true
            return
        }
        
        //  თანხის შემოწმება უნდა იყოს რიცხვი და > 0
        let formattedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(formattedAmount), amount > 0 else {
            alertMessage = "გთხოვთ შეიყვანოთ სწორი თანხა (ნულზე მეტი)."
            showAlert = true
            return
        }
        
        // თარიღის ფორმატირება ტექსტად (მაგ. "5 ნოემბერი")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ka_GE")
        dateFormatter.dateFormat = "d MMMM"
        let dateString = dateFormatter.string(from: selectedDate)
        
        // ახალი ობიექტის შექმნა და შენახვა
        let newExpense = Expense(
            title: trimmedTitle,
            amount: amount,
            category: selectedCategory,
            date: dateString
        )
        
        onSave(newExpense)
        dismiss()
    }
}

#Preview {
    ContentView()
}
