"
Stores an author of a Zotero document 

Mainly used to ease NeoJSON reading and writing of the authors
The #creatorType ""accessors"" are special because this field is assumed to be a constant,
therefore the setter that does not do anything and the getter returns this constant
"
Class {
	#name : #PharoteroAuthor,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'lastName'
	],
	#category : #'Pharotero-entities'
}

{ #category : #accessing }
PharoteroAuthor class >> firstName: firstname lastName: lastname [
	^self new
		firstName: firstname ;
		lastName: lastname ;
		yourself
]

{ #category : #accessing }
PharoteroAuthor class >> name:  aString [
	| parts |
	parts := ' ' split: aString.
	(parts size = 1) ifTrue: [ ^self firstName: '' lastName: aString ].
	^self firstName: (' ' join: parts allButLast) lastName: parts last


]

{ #category : #accessing }
PharoteroAuthor class >> neoJsonMapping: mapper [
	mapper
		for: PharoteroAuthor do: [ :mapping |
	      mapping mapAccessors: #(creatorType firstName lastName)
		]
]

{ #category : #accessing }
PharoteroAuthor >> creatorType [
	^'author'
]

{ #category : #accessing }
PharoteroAuthor >> creatorType: aString [ 

]

{ #category : #accessing }
PharoteroAuthor >> firstName [
	^ firstName
]

{ #category : #accessing }
PharoteroAuthor >> firstName: anObject [
	firstName := anObject
]

{ #category : #accessing }
PharoteroAuthor >> lastName [
	^ lastName
]

{ #category : #accessing }
PharoteroAuthor >> lastName: anObject [
	lastName := anObject
]
