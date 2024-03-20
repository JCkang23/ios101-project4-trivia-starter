//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

    import Foundation
    
    struct TriviaQuestion {
        let category: String
        let question: String
        let correctAnswer: String
        let incorrectAnswers: [String]
        let type: String = "boolean"
    }

    class TriviaQuestionService{
      static func fetchQuestions(completion: @escaping ([TriviaQuestion]) -> Void) {
          let url = URL(string: "https://opentdb.com/api.php?amount=5")!
          let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
              print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
              completion([])
              return
            }
            do {
              let decoder = JSONDecoder()
              let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
              // Map each TriviaQuestionData to a TriviaQuestion
              let triviaQuestions = triviaResponse.results.map { triviaQuestionData in
                return TriviaQuestion(
                  category: triviaQuestionData.category,
                  question: triviaQuestionData.question,
                  correctAnswer: triviaQuestionData.correct_answer,
                  incorrectAnswers: triviaQuestionData.incorrect_answers
                )
              }
              completion(triviaQuestions)
            } catch {
              print("Error decoding JSON: \(error.localizedDescription)")
              completion([])
            }
          }
          task.resume()
        }
    }
    struct TriviaResponse: Decodable {
      let results: [TriviaQuestionData]
    }
    struct TriviaQuestionData: Decodable {
      let category: String
      let question: String
      let correct_answer: String
      let incorrect_answers: [String]
    }
