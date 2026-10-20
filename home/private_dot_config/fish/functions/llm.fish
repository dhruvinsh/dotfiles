function llm --description 'Pipe llm output through streamdown'
    command llm $argv | streamdown
end
