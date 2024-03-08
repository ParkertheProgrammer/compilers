/**
 *        @file: cmos.cpp
 *      @author: Parker Corbitt
 *        @date: March 03, 2024
 *       @brief: cmos.cpp is a MOSS program for c code, used to detect plaugerism.
 */

#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <algorithm>
#include <limits>
#include <functional>
#include <map>
#include <string>
using namespace std;

/// function prototypes

/**
 * @brief Reads in all tokens from all_tokens.txt and removes unnecessary information (filename and whitespace)
 *
 * @param instream - input file stream
 * @param tokens - vector of strings to store the modified tokens
 */
void read_and_remove(ifstream &instream, vector<string> &tokens, vector<string> &filenames);

/**
 * @brief - Creates k
 *
 * @param tokens - vector of strings to store the modified tokens
 * @param k - size of the kmer
 * @return vector<vector<string>> - vector of kmers for each tokenized file
 */
vector<vector<string>> make_kmers(vector<string> &tokens, int k);

/**
 * @brief - Hashes all kmers in a vector of vectors of strings
 * 
 * @param kmers - vector of vectors of strings
 * @return vector<vector<long long>> - vector of vectors of hashed kmers
 */
vector<vector<long long>> hash_kmers(vector<vector<string>> &kmers);

/**
 * @brief - Hashes a kmer
 * 
 * @param kmer - string to be hashed
 * @return long long - hashed kmer
 */
long long hash_kmer(string kmer);

/**
 * @brief - Maps the minimum hashed kmer to the filename it came from
 * 
 * @param hashed_kmers - vector of vectors of hashed kmers
 * @param filenames - vector of filenames
 * @return vector<multimap<long long, string>> - vector of multimaps of hashed kmers and filenames
 */
vector<multimap<long long, string>> map_prints(vector<vector<long long>> &hashed_kmers, vector<string> &filenames, int w);

/**
 * @brief - Calculates the scores for each file pair
 * 
 * @param fingerprints_for_files - vector of multimaps of hashed kmers and filenames
 * @return vector<vector<double>> - vector of vectors of scores
 */
vector<vector<double>> calculate_scores(vector<multimap<long long, string>> &fingerprints_for_files);

/**
 * @brief - Prints the scores to a file in descending order of likelihood
 * 
 * @param scores - vector of vectors of scores denoting likelihood of plaguearism
 * @param threshold - minimum score to be printed
 */
void print_scores_to_file(const vector<vector<double>> &scores, double threshold);

int debug = 0;

int main(int argc, char const *argv[])
{
   int k;
   double t;
   int w;
   string file, token;
   ifstream instream;
   vector<string> tokens;
   vector<string> filenames;

   if (argc == 1)
   {
      k = 8;
      t = 0.875;
      w = 5;
   }
   else if (argc == 4)
   {
      k = atoi(argv[1]);
      t = atof(argv[2]);
      w = atoi(argv[3]);
   }
   else
   {
      cout << "Invalid arguments" << endl
           << "Usage: ./cmos [int k] [double t] [int w]" << endl;
   }

   // Read & Remove
   instream.open("all_tokens.txt");
   if (instream.fail())
   {
      cout << "File not found" << endl;
      exit(1);
   }

   read_and_remove(instream, tokens, filenames);

   // kmers
   vector<vector<string>> kmers = make_kmers(tokens, k);

   // Hash kmers
   vector<vector<long long>> hashed_kmers = hash_kmers(kmers);

   // Map prints
   vector<multimap<long long, string>> prints = map_prints(hashed_kmers, filenames, w);

   // Calculate scores
   vector<vector<double>> scores = calculate_scores(prints);

   // Print scores
   print_scores_to_file(scores, t);

   /*add code*/
   return 0;
} // main

void read_and_remove(ifstream &instream, vector<string> &tokens, vector<string> &filenames)
{
   string token;
   string filename;
   int filenumber = 1;
   while (instream >> filename)
   {
      filenames.push_back(filename);
      getline(instream, token);
      token.erase(remove(token.begin(), token.end(), ' '), token.end());
      tokens.push_back(token);

      if (debug == 1)
      {
         cout << "******TOKEN " << filenumber << "******" << endl;
         cout << token << endl;
      }
   }
}

vector<vector<string>> make_kmers(vector<string> &tokens, int k)
{
   vector<vector<string>> all_kmers;

   // For each token
   for (auto &token : tokens)
   {
      vector<string> kmers;

      // Go until size-k in order to leave room for the last kmer
      for (int i = 0; i <= token.size() - k; i++)
      {
         string kmer = token.substr(i, k);
         kmers.push_back(kmer);
      }

      all_kmers.push_back(kmers);
   }

   if (debug == 1)
   {
      for (int i = 0; i < all_kmers.size(); i++)
      {
         cout << "******TOKEN " << i + 1 << "******" << endl;
         for (int j = 0; j < all_kmers[i].size(); j++)
         {
            cout << "Kmer " << j + 1 << ": " << all_kmers[i][j] << endl;
         }
      }
   }

   return all_kmers;
}

vector<vector<long long>> hash_kmers(vector<vector<string>> &kmers)
{
   vector<vector<long long>> hashed_kmers;

   //for each token
   for (auto &token : kmers)
   {
      vector<long long> hashed_token;
      //for each kmer
      for (auto &kmer : token)
      {
         //hash the kmer
         long long hash = hash_kmer(kmer);
         hashed_token.push_back(hash);
      }
      hashed_kmers.push_back(hashed_token);
   }
   return hashed_kmers;
}

long long hash_kmer(string kmer)
{
std:
   hash<string> hash_fn;
   long long hash = hash_fn(kmer);
   return hash;
}

vector<multimap<long long, string>> map_prints(vector<vector<long long>> &hashed_kmers, vector<string> &filenames, int w)
{ 
   vector<multimap<long long, string>> fingerprints_for_files;

   for (size_t i = 0; i < hashed_kmers.size(); i++)
   {
      multimap<long long, string> fingerprints;
      for (int j = 0; j <= hashed_kmers[i].size() - w; j++)
      {
         auto min_it = min_element(hashed_kmers[i].begin() + j, hashed_kmers[i].begin() + j + w);
         fingerprints.insert({*min_it, filenames[i]});
      }
      fingerprints_for_files.push_back(fingerprints);
   }

   return fingerprints_for_files;
}

vector<vector<double>> calculate_scores(vector<multimap<long long, string>> &fingerprints_for_files)
{
   vector<vector<double>> scores(fingerprints_for_files.size(), vector<double>(fingerprints_for_files.size(), 0));

   for (size_t a = 0; a < fingerprints_for_files.size(); a++)
   {
      for (size_t b = a + 1; b < fingerprints_for_files.size(); b++)
      {
         int shared_fingerprints = 0;

         for (const auto &fingerprint : fingerprints_for_files[a])
         {
            if (fingerprints_for_files[b].count(fingerprint.first) > 0)
            {
               shared_fingerprints++;
            }
         }

         double score = static_cast<double>(shared_fingerprints) / fingerprints_for_files[a].size();
         scores[a][b] = score;
         scores[b][a] = score; // to ensure the matrix is symmetric
      }
   }

   return scores;
}

void print_scores_to_file(const vector<vector<double>> &scores, double threshold)
{
   // Create a multimap to store the scores and file pairs
   multimap<double, pair<size_t, size_t>, greater<double>> sorted_scores;

   for (size_t i = 0; i < scores.size(); i++)
   {
      for (size_t j = i + 1; j < scores[i].size(); j++)
      {
         if (scores[i][j] > threshold) // only store scores that are higher than the threshold
         {
            sorted_scores.insert({scores[i][j], {i + 1, j + 1}});
         }
      }
   }

   ofstream file("scores.txt");

   // Print the scores and file pairs in decreasing order
   for (const auto &score : sorted_scores)
   {
      file << "File " << setw(3) << score.second.first << "\tand \tFile \t" << setw(3) << score.second.second << ": \tScore \t= " << setw(10) << score.first << "\n";
   }

   file.close();
}