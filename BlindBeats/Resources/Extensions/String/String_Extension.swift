//
//  String_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/02/2025.
//

import Foundation

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
	
	public func normalized() -> String {
		
		let lower = self.lowercased()
		let folding = lower.folding(options: .diacriticInsensitive, locale: .current)
		let cleaned = folding.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: " ")
		
		// Supprimer les mots de liaison et mots inutiles
		let stopWords = [
			// Mots français
			"le", "la", "les", "un", "une", "des", "du", "de", "d", "et", "ou", "mais", "donc", "or", "ni", "car",
			"à", "au", "aux", "avec", "sans", "pour", "par", "sur", "sous", "dans", "entre", "vers", "chez",
			"ce", "cette", "ces", "mon", "ma", "mes", "ton", "ta", "tes", "son", "sa", "ses", "notre", "nos", "votre", "vos", "leur", "leurs",
			"je", "tu", "il", "elle", "nous", "vous", "ils", "elles", "me", "te", "se", "nous", "vous", "se",
			"qui", "que", "quoi", "dont", "où", "lequel", "laquelle", "lesquels", "lesquelles",
			"est", "sont", "était", "étaient", "sera", "seront", "être", "avoir", "faire", "dire", "aller", "voir", "savoir", "pouvoir", "vouloir",
			"très", "plus", "moins", "bien", "mal", "aussi", "encore", "déjà", "toujours", "jamais", "souvent", "parfois",
			"ici", "là", "où", "quand", "comment", "pourquoi", "parce", "que", "si", "comme", "alors", "donc",
			
			// Mots anglais
			"the", "a", "an", "and", "or", "but", "so", "yet", "for", "nor",
			"in", "on", "at", "to", "for", "of", "with", "by", "from", "up", "about", "into", "through", "during",
			"before", "after", "above", "below", "between", "among", "under", "over", "across", "around", "near",
			"this", "that", "these", "those", "my", "your", "his", "her", "its", "our", "their",
			"i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them",
			"who", "what", "where", "when", "why", "how", "which", "whose", "whom",
			"is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should",
			"very", "much", "more", "most", "less", "least", "good", "bad", "also", "still", "already", "always", "never", "often", "sometimes",
			"here", "there", "where", "when", "how", "why", "because", "if", "as", "then", "so", "now"
		]
		
		let words = cleaned.components(separatedBy: .whitespacesAndNewlines)
		let filteredWords = words.filter { word in
			!word.isEmpty && !stopWords.contains(word)
		}
		
		return filteredWords.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
		// MARK: - Simplification phonétique (anglais + français)
	private func phoneticKey() -> String {
		var s = self.normalized()
		
		let replacements: [String: String] = [
			// Sons anglais fréquents
			"ph": "f", "ght": "t", "kn": "n", "wr": "r", "wh": "w",
			"qu": "k", "ck": "k", "ch": "sh", "sh": "sh", "th": "t",
			"dh": "d", "gh": "g", "oo": "u", "ee": "i", "ea": "i",
			"ai": "e", "ay": "e", "ey": "i", "ie": "i",
			"ei": "i", "y": "i", "z": "s", "c": "k", "x": "ks",
			
			// Sons français fréquents
			"an": "on", "en": "on", "in": "ain", "ain": "in", "ein": "in",
			"on": "on", "un": "in", "ien": "in", "oi": "wa", "ou": "u",
			"eau": "o", "au": "o", "eu": "e", "oeu": "e"
		]
		
		for (pattern, replacement) in replacements {
			s = s.replacingOccurrences(of: pattern, with: replacement)
		}
		
		s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
		return s.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
		// MARK: - Distance de Levenshtein
	private func levenshteinDistance(to rhs: String) -> Int {
		let lhs = Array(self)
		let rhs = Array(rhs)
		var dist = [[Int]](repeating: [Int](repeating: 0, count: rhs.count + 1), count: lhs.count + 1)
		
		for i in 0...lhs.count { dist[i][0] = i }
		for j in 0...rhs.count { dist[0][j] = j }
		
		for i in 1...lhs.count {
			for j in 1...rhs.count {
				if lhs[i-1] == rhs[j-1] {
					dist[i][j] = dist[i-1][j-1]
				} else {
					dist[i][j] = Swift.min(
						dist[i-1][j] + 1,
						dist[i][j-1] + 1,
						dist[i-1][j-1] + 1
					)
				}
			}
		}
		return dist[lhs.count][rhs.count]
	}
	
		// MARK: - Score de similarité (0.0 à 1.0)
	public func similarityScore(to other: String?) -> Double {
		
		if let other {
			
			let n1 = self.normalized()
			let n2 = other.normalized()
			
			guard !n1.isEmpty, !n2.isEmpty else { return 0.0 }
			
				// Score direct
			let distance = n1.levenshteinDistance(to: n2)
			let maxLength = max(n1.count, n2.count)
			let directScore = 1.0 - (Double(distance) / Double(maxLength))
			
				// Score phonétique
			let p1 = n1.phoneticKey()
			let p2 = n2.phoneticKey()
			let phoneticDistance = p1.levenshteinDistance(to: p2)
			let maxPhonetic = max(p1.count, p2.count)
			let phoneticScore = 1.0 - (Double(phoneticDistance) / Double(maxPhonetic))
			
			return (directScore * 0.6) + (phoneticScore * 0.4)
		}
		
		return 0.0
	}
}
