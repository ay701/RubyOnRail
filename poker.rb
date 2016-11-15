############################################################
# Project Description
# https://projecteuler.net/problem=54
#  
# Data Source
# https://projecteuler.net/project/resources/p054_poker.txt
#
# In the card game poker, a hand consists of five cards and are ranked, from lowest to highest, in the following way:
# 
# High Card: Highest value card.
# One Pair: Two cards of the same value.
# Two Pairs: Two different pairs.
# Three of a Kind: Three cards of the same value.
# Straight: All cards are consecutive values.
# Flush: All cards of the same suit.
# Full House: Three of a kind and a pair.
# Four of a Kind: Four cards of the same value.
# Straight Flush: All cards are consecutive values of same suit.
# Royal Flush: Ten, Jack, Queen, King, Ace, in same suit.
#
############################################################

require 'open-uri'

class Player

    def initialize(hand)
	@royal_flush = ['T','J','Q','K','A']
        @cards = hand.split(" ")
        @levels = { 
        			"Royal Flush"=>0, # level as key, max as value
        		   	"Straight Flush"=>0, 
        		   	"Four of a Kind"=>0, 
        		   	"Full House"=>0, 
        		   	"Flush"=>0, 
        		   	"Straight"=>0, 
        		   	"Three of a Kind"=>0, 
        		   	"Two Pairs"=>0, 
        		   	"One Pair"=>0, 
        		   	"High Card"=>0 
        		   }  

        @card_types = Hash.new(0)  # card number as key, occurrance as value
        @card_suits = Hash.new([])  # card number as key, suit list as value         
    end

    def calculate
    	sorted_cards = Array.new

    	@cards.each do |card|
    		card_num = card[0]
        	@card_types[card_num] += 1
        	@card_suits[card_num] += [card[1]]
            @royal_flush.delete(card_num)

            if sorted_cards.empty? or PokerGame::VALUE_MAP[sorted_cards[-1]]<=PokerGame::VALUE_MAP[card_num]
                sorted_cards.push(card_num)
            elsif PokerGame::VALUE_MAP[sorted_cards[0]]>=PokerGame::VALUE_MAP[card_num]
                sorted_cards = [card_num] + sorted_cards
            else
                cnt = sorted_cards.length
                (0...cnt-1).step(1) do |i|
                    if PokerGame::VALUE_MAP[sorted_cards[i]]<=PokerGame::VALUE_MAP[card_num] and 
                    	PokerGame::VALUE_MAP[card_num]<PokerGame::VALUE_MAP[sorted_cards[i+1]]
                    	sorted_cards = sorted_cards[0..i]+[card_num]+sorted_cards[i+1..cnt]
                    	break
                    end
                end
            end

            # puts sorted_cards.join(" ")
        end

        # Calculate Royal Flush
        if @royal_flush.length==0 and 
        	@card_suits["T"]==@card_suits["J"] and
        	@card_suits["J"]==@card_suits["Q"] and
        	@card_suits["Q"]==@card_suits["K"] and
        	@card_suits["K"]==@card_suits["A"]
        	@levels["Royal Flush"] = 1 
    	end

    	# Variables for all rules
        straight_flush_max = pair_max = flush_max = max_ = last = sorted_cards[0]
        is_straight_flush = is_flush = true
        pair_cnt = 0
        pairs = Array.new
        
        # Sort cards
		sorted_cards[1..4].each do |current|
			gap = PokerGame::VALUE_MAP[current].to_i - PokerGame::VALUE_MAP[last].to_i 

        	if is_straight_flush 
        		if gap!=1 or @card_suits[current]!=@card_suits[last]
        			is_straight_flush = false
        		else
        			straight_flush_max = current
        		end
        	end

        	if gap==0
        		pair_cnt += 1
        		pair_max = current
        	elsif pair_cnt==1
        		pairs.push(last)
        		pair_cnt = 0
        	end

        	if is_flush 
        		if @card_suits[current]!=@card_suits[last]
        			is_flush = false
	        	else
    	    		flush_max = current  
        		end
        	end  		

        	if PokerGame::VALUE_MAP[current]>PokerGame::VALUE_MAP[max_]
        		max_ = current
        	end

        	last = current

        end

        # Check if pair left not being processed 
        if pair_cnt==1
        	pairs.push(last)
        end

        # Set "Straight Flush" with max value
        if is_straight_flush
        	@levels["Straight Flush"] = straight_flush_max
        end

        # Set "Four of a Kind" with max value
        if pair_cnt==3
            @levels["Four of a Kind"] = pair_max
        end

        # Set "Full House" with max value
        if pair_cnt==2 and pairs.length==1
            @levels["Full House"] = pairs[-1]
        end

        # Set "Flush" with max value
        if is_flush
        	@levels["Flush"] = flush_max
        end

        # Set "Three of a Kind" with max value
        if pair_cnt==2
        	@levels["Three of a Kind"] = pair_max
        end

        # Set "Two Pairs" with max value
        if pairs.length==2
        	@levels["Two Pairs"] = pair_max
        end

        # Set "One Pair" with max value
        if pairs.length==1
        	@levels["One Pair"] = pair_max
        end
    	
        # Set "High Card" with max value
        @levels["High Card"] = max_

    end

    def getLevel
    	n = 1
    	@levels.each do |level, value|
    		if value!=0
    			return n, value, level   # Return array 
    		end

    		n += 1
    	end
    end

end 

class PokerGame

	# Constant : {card number => int value}
    VALUE_MAP = { 
    				"2"=>2, 
    				"3"=>3, 
    				"4"=>4, 
    				"5"=>5, 
    				"6"=>6, 
    				"7"=>7, 
    				"8"=>8, 
    				"9"=>9, 
    				"T"=>10, 
    				"J"=>11, 
    				"Q"=>12, 
    				"K"=>13, 
    				"A"=>14 
    			}

	def initialize(filename)
		@win_cnt = 0
		@filename = filename
	end

	def work
		line_num = 1

		# IO.foreach(@filename){ 
		# Open URI file
		open(@filename){ |f|
			f.each_line {
				|line|
			
				cnt = line.length 
				mid = cnt/2 
			    player_1 = Player.new(line[0...mid].strip)
			    player_2 = Player.new(line[mid...cnt].strip)
			    
			    player_1.calculate
			    player_2.calculate
			    
			    level_1 = player_1.getLevel
			    level_2 = player_2.getLevel

			    # puts level_1.join(" "), level_2.join(" ") 

			    if level_1[0]<level_2[0]
			    	@win_cnt += 1
			    elsif level_1[0] == level_2[0] and VALUE_MAP[level_1[1]] > VALUE_MAP[level_2[1]] 
			    	@win_cnt += 1
			    end

			    line_num += 1
			}
		}
	end

	def showResult
		puts @win_cnt
    end
end
   
# poker = Poker.new("in.txt")
# poker = Poker.new("p054_poker.txt")
poker = PokerGame.new("https://projecteuler.net/project/resources/p054_poker.txt")
poker.work
poker.showResult

# Total 379 hands Player 1 won
