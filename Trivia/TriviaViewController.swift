//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    // TODO: FETCH TRIVIA QUESTIONS HERE
      
      // Fetch trivia questions when the view loads initially
              fetchNewQuestions()
          }
          private func fetchNewQuestions() {
              TriviaQuestionService.fetchQuestions { [weak self] questions in
                  // Reset game state
                  self?.currQuestionIndex = 0
                  self?.numCorrectQuestions = 0
                  // Update questions array
                  self?.questions = questions
                  // Update UI with the first question
                  if let firstQuestion = questions.first {
                      self?.configure(with: firstQuestion)
                  }
              }
          }
    
          private func updateQuestion(withQuestionIndex questionIndex: Int) {
              currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
              let question = questions[questionIndex]
              questionLabel.text = question.question.convertHTMLEntities()
              categoryLabel.text = question.category.convertHTMLEntities()
              let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
              if answers.count > 0 {
                  answerButton0.setTitle(answers[0].convertHTMLEntities(), for: .normal)
              }
              if answers.count > 1 {
                  answerButton1.setTitle(answers[1].convertHTMLEntities(), for: .normal)
                  answerButton1.isHidden = false
              }
              if answers.count > 2 {
                  answerButton2.setTitle(answers[2].convertHTMLEntities(), for: .normal)
                  answerButton2.isHidden = false
              }
              if answers.count > 3 {
                  answerButton3.setTitle(answers[3].convertHTMLEntities(), for: .normal)
                  answerButton3.isHidden = false
              }
          }
          func configure(with question: TriviaQuestion) {
              currentQuestionNumberLabel.text = "Question: \(currQuestionIndex + 1)/\(questions.count)"
              let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
              questionLabel.text = question.question.convertHTMLEntities()
              categoryLabel.text = question.category.convertHTMLEntities()
              if question.type == "boolean" {
                  answerButton0.isHidden = false
                  answerButton1.isHidden = false
                  answerButton2.isHidden = true
                  answerButton3.isHidden = true
                  answerButton0.setTitle(answers[0].convertHTMLEntities(), for: .normal)
                  answerButton1.setTitle(answers[1].convertHTMLEntities(), for: .normal)
              } else if question.type == "multiple" {
                  answerButton0.isHidden = false
                  answerButton1.isHidden = false
                  answerButton2.isHidden = false
                  answerButton3.isHidden = false
                  answerButton0.setTitle(answers[0].convertHTMLEntities(), for: .normal)
                  answerButton1.setTitle(answers[1].convertHTMLEntities(), for: .normal)
                  answerButton2.setTitle(answers[2].convertHTMLEntities(), for: .normal)
                  answerButton3.setTitle(answers[3].convertHTMLEntities(), for: .normal)
              }
          }
          private func updateToNextQuestion(answer: String) {
              if isCorrectAnswer(answer) {
                  numCorrectQuestions += 1
              }
              currQuestionIndex += 1
              guard currQuestionIndex < questions.count else {
                  showFinalScore()
                  return
              }
              updateQuestion(withQuestionIndex: currQuestionIndex)
          }
          private func isCorrectAnswer(_ answer: String) -> Bool {
              return answer == questions[currQuestionIndex].correctAnswer
          }
          private func showFinalScore() {
              let alertController = UIAlertController(title: "Game over!",
                                                      message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                      preferredStyle: .alert)
              let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
                  currQuestionIndex = 0
                  numCorrectQuestions = 0
                  updateQuestion(withQuestionIndex: currQuestionIndex)
                  self.fetchNewQuestions()
              }
              alertController.addAction(resetAction)
              present(alertController, animated: true, completion: nil)
          }
          private func addGradient() {
              let gradientLayer = CAGradientLayer()
              gradientLayer.frame = view.bounds
              gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                      UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
              gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
              gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
              view.layer.insertSublayer(gradientLayer, at: 0)
          }
          @IBAction func didTapAnswerButton0(_ sender: UIButton) {
              handleAnswer(forButtonIndex: 0)
          }
          @IBAction func didTapAnswerButton1(_ sender: UIButton) {
              handleAnswer(forButtonIndex: 1)
          }
          @IBAction func didTapAnswerButton2(_ sender: UIButton) {
              handleAnswer(forButtonIndex: 2)
          }
          @IBAction func didTapAnswerButton3(_ sender: UIButton) {
              handleAnswer(forButtonIndex: 3)
          }
          private func handleAnswer(forButtonIndex buttonIndex: Int) {
              let selectedAnswer = buttonIndex == 0 ? answerButton0.titleLabel?.text : buttonIndex == 1 ? answerButton1.titleLabel?.text : buttonIndex == 2 ? answerButton2.titleLabel?.text : answerButton3.titleLabel?.text
              let isCorrect = isCorrectAnswer(selectedAnswer ?? "")
              if isCorrect {
                  numCorrectQuestions += 1
              }
              currQuestionIndex += 1
              guard currQuestionIndex < questions.count else {
                  showFinalScore()
                  return
              }
              configure(with: questions[currQuestionIndex])
          }
      }
      extension String {
          func convertHTMLEntities() -> String? {
              guard let data = self.data(using: .utf8) else {
                  return nil
              }
              do {
                  let attributedString = try NSAttributedString(data: data,
                                                                options: [.documentType: NSAttributedString.DocumentType.html],
                                                                documentAttributes: nil)
                  return attributedString.string
              } catch {
                  print("Error converting HTML entities: \(error)")
                  return nil
              }
          }
      }
