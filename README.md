# PastaParser

[![CI Status](https://img.shields.io/travis/NoodleOfDeath/PastaParser.svg?style=flat)](https://travis-ci.org/NoodleOfDeath/PastaParser)
[![Version](https://img.shields.io/cocoapods/v/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)
[![License](https://img.shields.io/cocoapods/l/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)
[![Platform](https://img.shields.io/cocoapods/p/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)

The goal of PastaParser is to provide a lightweight and extensible framework for tokenizing and parsing stream of characters using a user defined grammar definition that can attribute meaning to occurrences and/or sequences of characters that match any number of custom rules belonging to that grammar. Using this framework should allow developers to not only define any number of custom languages _without the need for a complete project rebuild_ (just the addition of a simple XML file and/or ParserParser grammar package with the <code>.ppgrammar</code> extension) but also use this engine to apply syntax highlighting, identifier and scope recognition, and code recommendation/autocompletion in their applications.

Support to import and convert ANTLR4 grammar files to PastaParser grammar file format is a long term goal of this project, as well.

## Development Workflow Overview

In order to make the most of this engine, the developer needs to be well educated on grammar theory,
syntactical analysis, and abstract syntax trees. The engine itself is only as powerful as the grammar
library files it implements. The following is a simple outline of a possible workflow to incorporate this
framework into an application; note that the steps are not listed in any particular order.

- [Installation](#installation)
- [Define Grammars](#define-grammars)
- [Handle Grammar Events](#handle-grammar-events)

## Installation

### iOS/macOS - Swift (CocoaPods)

```ruby
pod 'PastaParser'
```

### Java (Maven) - NOT YET SUPPORTED

```xml  
<dependency>
	<groupId>com.noodleofdeath</groupId>
	<artifactId>pastaparser</artifactId>
	<version>1.0.0</version>
</dependency>
```

## Author

NoodleOfDeath, git@noodleofdeath.com

## License

PastaParser is available under the MIT license. See the LICENSE file for more info.

## Example and Usage

### iOS/macOS - Swift (CocoaPods)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
import XCTest
import PastaParser

class Tests: XCTestCase {

    func testExample() {
        guard
            let grammarsDirectory = Bundle(for: type(of: self)).resourcePath?.ns.appendingPathComponent("grammars"),
            let sampleFile = Bundle(for: type(of: self)).path(forResource: "samples/Test", ofType: "swift")
            else { XCTFail(); return }
        let loader = PPGrammarLoader(searchPaths: grammarsDirectory)
        do {
            guard let grammar = loader.load(with: "public.swift-source") else { XCTFail(); return }
            let text = try String(contentsOfFile: sampleFile)
            let engine = PPCompoundGrammarEngine(grammar: grammar)
            engine.process(text, options: .verbose)
        } catch {
            print(error)
            XCTFail()
        }
    }

}
```

### Java (Maven)

To run the example project, clone the repo, and run the Eclipse project as Java Application and/or JUnit test.

```java
import static org.junit.Assert.fail;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.junit.Test;

import com.noodleofdeath.pastaparser.io.engine.SyntaxEngine;
import com.noodleofdeath.pastaparser.io.engine.impl.BaseTextSyntaxEngine;
import com.noodleofdeath.pastaparser.io.lexer.Lexer;
import com.noodleofdeath.pastaparser.io.parser.Parser;
import com.noodleofdeath.pastaparser.io.token.TextToken;
import com.noodleofdeath.pastaparser.model.grammar.Grammar;
import com.noodleofdeath.pastaparser.model.grammar.loader.GrammarLoader;
import com.noodleofdeath.pastaparser.model.grammar.loader.impl.BaseGrammarLoader;

class PastaParserSystemTest {

	private static String SAMPLES_DIRECTORY = "../../samples";
	private static String GRAMMARS_DIRECTORY = "../../grammars";

	public static void main(String[] args) throws Exception {
		testGrammar();
	}

	@Test
	public static void testGrammar() throws Exception {

		File file = new File(SAMPLES_DIRECTORY + "/Test.swift");
		FileInputStream fis;
		String characterStream = "";
		try {
			fis = new FileInputStream(file);
			byte[] data = new byte[(int) file.length()];
			fis.read(data);
			fis.close();
			characterStream = new String(data, "UTF-8");
		} catch (FileNotFoundException error) {
			error.printStackTrace();
			fail();
		} catch (IOException error) {
			error.printStackTrace();
			fail();
		}

		GrammarLoader loader = new BaseGrammarLoader(GRAMMARS_DIRECTORY);
		
		Grammar grammar = loader.load("public.swift-source");
		SyntaxEngine<String, TextToken, Lexer<String, TextToken>, Parser<String, TextToken>> engine = new BaseTextSyntaxEngine(grammar);
		engine.process(characterStream, true);

	}

}
```

## Define Grammars

In version 1.0.0, grammars are defined as a single xml file or a directory package ending in the <code>.ppgrammar</code>
suffix, which contain a single <code>grammar.xml</code> file that defines the grammar rules. Future releases will support
grammar definitions as plain text ANTLR4 <code>.g4</code> files. The purpose of packaged grammars is allow for assets to 
be bundled with a grammar in custom implementations.

### Root Grammar Element

PastaParser XML grammar definitions follow many of the same rules as plain text ANTLR4 grammar definitions. At a minimum
PastaParser XML grammar definitions are required to have a root <code>grammar</code> element. This element can have
a <code>grammar-structure</code>, <code>grammar-type</code>, and <code>version</code> attributes. The <code>grammar-structure</code>
attribute will always be <code>1.0</code> until newer grammar structure models are released. The <code>grammar-type</code>
attribute can currently be 1 of three values: <code>lexer</code>, <code>parser</code>, and <code>compound</code>. If
this attribute is omitted, the grammar is assumed to be a lexer grammar. Below is a simple example of a grammar root element
for a compound grammar:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<grammar grammar-structure="1.0" grammar-type="compound" version="1.0">
    <lexer-rules>
    
    </lexer-rules>
    <parser-rules>
    
    </parser-rules>
</grammar>
```

### Grammar Rules

#### Grammar Rule Attributes

Grammars are made up of grammar rules. These rules are defined as semi-regex/ANTLR4 grammar rule variants. In a lexer
grammar, there must be an element array named <code>lexer-rules</code>; in a parser grammar, there must be an element
array named <code>parser-rules</code>; and in a compound grammar, both element arrays must exist. Each element array
contains a sequential list of <code>rule</code> elements. Each grammar rule must have an <code>id</code> attribute,
and may also have <code>order</code> and <code>options</code> attributes as shown in the example below.

Rules with an <code>id</code> that starts with a lowercase letter will be treated as lexer rules, and rules with an
<code>id</code> that begins with an uppercase letter will be treated as parser rules.

```xml
<rule id="MyRule" order="100" options="omit skip">
    ...
</rule>
```

##### Order Attribute

The <code>order</code> attribute defines the priority of the rule. Rules with lower value order will, by default,
be tested against an input stream before rules with higher value order. This attribute is used to sort rules by
calling the <code>sortRules</code> method of the <code>Grammar</code> class.

##### Options Attribute

The <code>options</code> attribute of a rule tells the lexer/parser engine how to handle events when this rule
matches a sequence in an input stream. Multiple options can be listed in this attribute separated by at least
a single whitespace character and/or a single comma. If the <code>skip</code> option is specified, matches
to this rule will not fire a grammar event to pass on to listeners/delegates. A skipped match will still terminate
processing of other rules of greater order as well as increment the current index of the input stream. An example
of this would be to skip all whitespace character matches but continue to advance forward in the input stream. If the
<code>omit</code> option is specified, the rule will not be added to the queue of matchable rules, however, it
can be referenced by other rules by <code>id</code>. An example of using this would be when several rules reuse
a rule expression, but the rule expression by itself should not generate a grammar event upon matching.

#### Grammar Rule Definition

A grammar rule must contain a single <code>definition</code> element that specifies a sequence of patterns
and/or subrules that when encountered in an input stream will generate a grammar event. Single quoted strings will
be treated as raw regular expression. Rules may reference other rules, and even reference themeselves
recursively as long as they are not fatally recursive causing an infinte loop. Lexer rules may reference other
lexer rules, but NOT parser rules. Parser rules may reference both lexer and parser rules.

-- TODO --

#### Grammar Rule Definition Quantifiers

Each component in a rule definition may also have a postfix quantifier operator indicating how many times to
match that component in a sequence and/or if it is an optional component. For example, this can be defined
both as a regular expression and as a postfix quantifier as shown below.

-- TODO --

```xml
<rules>
    <!-- This is a lexer rule -->
    <rule id="SPACE" order="1" category="whitespace" options="skip">
        <definition>'[ ]'</definition>
    </rule>
    <!-- This is another lexer rule -->
    <rule id="TAB" order="1" category="whitespace" options="skip">
        <definition>'\t'</definition>
    </rule>
    <!-- This is a parser rule -->
    <rule id="four-whitespaces" order="1" category="whitespace" options="skip">
        <definition>(SPACE || TAB){4}</definition>
    </rule>
</rules>
```

#### Grammar Rule Metadata

```xml
<lexer-rules>
    <rule id="NUMBER" order="7000" category="number" options="">
        <definition>'0x[0-9a-fA-F][0-9a-fA-F]+' | ('[0-9]+' ('\.[0-9]+')?)</definition>
        <meta>
            <category>number</category>
        </meta>
    </rule>
</lexer-rules>
```

### Grammar Rule Types

-- TODO --

## Handle Grammar Events

The PastaParser lexer and parser engines will automatically trigger grammar events any time a lexer/parser rule
is matched in a character/token stream provided to it.

-- TODO --
